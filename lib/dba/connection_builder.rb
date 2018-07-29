require 'uri'
require 'pg'
require 'forwardable'
require "active_support/core_ext/hash/keys"
require_relative 'db_cli'
require_relative 'script_runner'
require_relative 'querying'

class Dba::ConnectionBuilder
  include Dba::Querying

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
    url += get_part_if(opts, :host) 
    url += get_part_if(opts, :port, prefix: ':') 
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
    opts = attrs.each_with_object({}) do |i, memo|
      if uri.respond_to?(i)
        s = i
        memo[s] = uri.send(i)
      end
    end
    # /path1 => dbname1
    opts[:dbname] = opts.delete(:path).sub(/^\//, '')
    opts
  end

  def dbtype
    uri.scheme
  end

  def dbname
    options[:dbname]
  end

  def unique_id
    [dbname, host, port || '5432'].join('.')
  end
  alias_method :uid, :unique_id

  def dbdomain
    [dbname, host].join('.')
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

  def cli(runner: nil)
    case dbtype
    when /^postgres/
      Dba::DbCli.exec url, runner: runner
    end
  end

  def script_runner
    @_script_runner ||= Dba::ScriptRunner.new(self)
  end

  ################################################
  #          connection
  
  def connection
    @connection ||= retrieve_connection
  end

  def retrieve_connection
    case dbtype
    when /^postgres/
      PG::Connection.open(conn_hash)
    end
  end

  def close!
    return unless @connection
    @connection.close if @connection.respond_to?(:close) 
    @connection = nil
  end

  def try_connect!
    c = retrieve_connection 
  rescue PG::ConnectionBad => e
    #PG::ConnectionBad: FATAL:  database "missing_db" does not exist
    if e.message =~ /does not exist/
      raise DbNotExistError.new(e.message)
    else
      raise ConnectError.new(e.message)
    end
  rescue => e
    raise ConnectError.new(e.message)
  ensure
    c&.close
  end

  def db_not_exist?
    try_connect!
    false
  rescue DbNotExistError => e
    true
  end

  def run_sql(query, params = nil)
    result = if params
      connection.exec_params(query, params)
    else
      connection.exec(query)
    end

    if block_given?
      yield(result)
      close!
    end

    ResultStatus.new(result, conn: self)
  rescue => e
    ResultStatus.new(e)
  end
  alias_method :exec, :run_sql

  def fork(opts = {})
    opts = options.merge(opts)
    conn = self.class.new(opts)
    if block_given?
      yield conn
      conn.close!
    end
    conn
  end

  # https://www.postgresql.org/docs/9.2/static/libpq-connect.html#LIBPQ-PARAMKEYWORDS
  def conn_hash
    # no scheme required!!!
    options.slice(*%i(user password host port dbname))
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

  class ConnectError < StandardError; end
  class DbNotExistError < ConnectError; end

  class ResultStatus
    attr_reader :result, :conn

    def initialize(e, conn: nil)
      @conn = conn
      @result = e 
      if failed?
        puts "==fail: #{e.class} #{e.message}!" 
      end
    end

    def failed?
      @result.is_a?(Exception)
    end

    # sql result values
    def values
      return if failed?
      result.values
    end

    # todo beautiful table
    def output
      return unless values
      values.each do |r|
        puts r.join ' '
      end
      nil
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

    def close
      conn&.close!
      self
    end

    def to_s
      result.to_s
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
