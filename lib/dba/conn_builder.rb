require 'uri'
require 'pg'
require "active_support/core_ext/hash/keys"

require_relative 'db_cli'

class Dba::ConnBuilder

  attr_accessor :url, :options, :connid
  attr_reader   :uri

  def initialize(opts = {})
    opts.symbolize_keys!
    @url = opts.delete(:url)
    if @url
      # escape first?
      @uri = URI(@url) 
      @options = build_options(@uri)
    else
      opts[:scheme] ||= opts.delete(:dbtype)
      @options = opts
      @url = build_url(opts)
      @uri = URI(@url) 
    end
  end

  def build_url(opts)
    url = ""
    url += get_part_if(opts, :scheme, suffix: '://') 
    user = get_part_if(opts, :user) 
    passwd = get_part_if(opts, :password) 
    if user.length > 0 || passwd.length > 0
      url += "#{user}:#{passwd}@"
    end
    url += get_part_if(opts, :host, suffix: ':') 
    url += get_part_if(opts, :port) 
    url += get_part_if(opts, :dbname, prefix: '/')
    url += get_part_if(opts, :query, prefix: '?') 
    #url += get_part_if(opts, :fragment, prefix: '#') 
    url
  end 

  def get_part_if(opts, key, prefix: nil, suffix: nil)
    val = opts[key]
    val ? "#{prefix}#{val}#{suffix}" : ''
  end

  def build_options(uri)
    attrs = %i(scheme user password host port path query fragment)
    attrs.each_with_object({}) do |i, memo|
      if uri.respond_to?(i)
        memo[i] = uri.send(i)
      end
    end
  end

  def dbtype
    uri.scheme
  end

  def dbname
    options[:dbname]
  end

  def info
    {
      url: url,
      options: options
    }
  end

  def to_s
    "#{connid} #{url}"
  end

  def cli
    case dbtype
    when /^postgres/
      DbCli.pgcli url
    end
  end

  ################################################
  #          connection
  
  def connection
    @connection ||= case dbtype
      when /^postgres/
        PG::Connection.open(conn_hash)
      end
  end

  def close!
    return unless @connection
    @connection.close if @connection.respond_to?(:close) 
    @connection = nil
  end

  def sql(query, params = nil)
    result = if params
      connection.exec_params(query, params)
    else
      connection.exec(query)
    end

    if block_given?
      yield(result)
      close!
    end

    ResultStatus.new(result)
  rescue => e
    ResultStatus.new(e)
  end

  # https://www.postgresql.org/docs/9.2/static/libpq-connect.html#LIBPQ-PARAMKEYWORDS
  def conn_hash
    # no scheme required!!!
    options.slice(*%i(user host port dbname))
  end

  def conn_str
    conn_hash.map{|k, v| "--#{k}=#{v}" }.join(' ')
  end

  def method_missing(name, *args, &blk)
    if uri.respond_to?(name)
      uri.send(name, *args, &blk)
    else
      super
    end
  end

  class ResultStatus
    attr_reader :result, :failed

    def initialize(e)
      @result = e 
      if failed? && ENV['DEBUG']
        puts "==fail: #{e.class} #{e.message}!" 
      end
    end

    def failed?
      @result.is_a?(Exception)
    end

    #ERROR:  permission denied for schema data
    def denied?
      result.is_a?(PG::InsufficientPrivilege) || result.is_a?(PG::ConnectionBad)
      #FATAL:  permission denied for database "cms"
      #DETAIL:  User does not have CONNECT privilege
    end

    def allowed?
      !denied?
    end

    def method_missing(name, *args, &blk)
      if result.respond_to?(name)
        result.send(name, *args, &blk)
      else
        super
      end
    end
  end
end
