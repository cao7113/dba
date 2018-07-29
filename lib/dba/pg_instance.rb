require 'fileutils'

class Dba::PgInstance
  attr_reader :options, :conn_hash
  attr_accessor :cmds, :data_dir

  DEFAULT_CONN_HASH = {
    scheme: 'postgres',
    host:   '0.0.0.0',
    port:   7654, # dynamic???
    user:   'dbauser',
    dbname: 'dbauser'
  }
  attr_reader *DEFAULT_CONN_HASH.keys

  def initialize(opts = {})
    @options = opts
    @conn_hash = {}
    DEFAULT_CONN_HASH.each do |k, v|
      val = opts[k] || opts[k.to_s] || v
      instance_variable_set("@#{k}", val)
      @conn_hash[k] = val
    end

    @cmds = {}
    @data_dir = opts.fetch(:data_dir){ "/tmp/pg_instance_#{@port}" }
  end

  def self.setup(opts = {})
    pg = new(opts)
    pg.setup
    if block_given?
      yield pg 
      pg.cleanup!
    end
    pg
  end

  def setup()
    create_data_dir
    initdb
    rundb
    setup_init_user
    setup_init_database
  end

  def create_data_dir()
    Dir.mkdir(@data_dir) unless File.exists? @data_dir
  end

  def initdb()
    shell_out "#{cmd_path(:initdb)} #{@data_dir} -A trust -E utf-8"
  end

  def rundb()
    pid = Process.fork { shell_out "#{cmd_path(:pg_ctl)} start -o '-p #{port}' -D #{@data_dir}" }
    # give a second for postgresql to startup
    sleep(1)
    Process.detach(pid)
    wait_until_ready #if options[:wait_ready]
  end

  def wait_until_ready(ttl = 30)
    past = 0
    while past < ttl 
      break if is_ready?
      step = 0.5
      sleep step
      past += step
      printf "\rWaiting #{past} seconds to pg ready"
    end
  end

  def is_ready?
    system "#{cmd_path(:pg_isready)} -h #{host} -p #{port} > /dev/null"
  end

  def setup_init_user()
    shell_out "#{cmd_path(:createuser)} -s -p #{port} -l #{user} -w"
  end

  def setup_init_database()
    shell_out "#{cmd_path(:createdb)} -p #{port} #{dbname} -O #{user}"
  end

  def cleanup!()
    shell_out "#{cmd_path(:pg_ctl)} stop -m fast -o '-p #{port}' -D #{data_dir}"
    remove_data_dir
  end
  alias_method :teardown, :cleanup!

  def remove_data_dir()
    FileUtils.remove_dir(@data_dir)
  end

  # eg. initdb pg_ctl psql
  def cmd_path(name = :psql)
    name = name.to_sym
    val = @cmds[name]
    return val if val
    val = options[name] || shell_out("which #{name}")
    raise "#{name} not found!" unless val
    @cmds[name] = val
  end

  private

  def shell_out(cmd)
    result = `#{cmd}`
    result.strip
  end
end
