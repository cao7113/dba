require 'fileutils'

class Dba::PgInstance
  attr_reader :options, :conn_hash
  attr_reader :initdb_path, :pgctl_path, :psql_path, 
              :createuser_path, :createdb_path, :data_dir

  DEFAULT_CONN_HASH = {
    scheme: 'postgres',
    host:   '0.0.0.0',
    port:   7654, # dynamic???
    user:   'dbauser',
    dbname: 'try'
  }
  attr_reader *DEFAULT_CONN_HASH.keys

  def initialize(opts = {})
    @options         = opts
    @initdb_path     = opts.fetch(:initdb_path) { shell_out('which initdb') }
    @pgctl_path      = opts.fetch(:pgctl_path) { shell_out('which pg_ctl') }
    @psql_path       = opts.fetch(:psql_path) { shell_out('which psql') }
    @pg_isready_path = opts.fetch(:isready_path) { shell_out('which pg_isready') }
    @createuser_path = opts.fetch(:createuser_path) { shell_out('which createuser') }
    @createdb_path   = opts.fetch(:createdb_path) { shell_out('which createdb') }

    @conn_hash = {}
    DEFAULT_CONN_HASH.each do |k, v|
      val = opts[k] || opts[k.to_s] || v
      instance_variable_set("@#{k}", val)
      @conn_hash[k] = val
    end
    @data_dir        = opts.fetch(:data_dir) { "/tmp/pg_instance_#{@port}" }

    raise 'please install postgresql' unless @initdb_path && !@initdb_path.empty?
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
    shell_out "#{@initdb_path} #{@data_dir} -A trust -E utf-8"
  end

  def rundb()
    pid = Process.fork { shell_out "#{@pgctl_path} start -o '-p #{port}' -D #{@data_dir}" }
    # give a second for postgresql to startup
    sleep(1)
    Process.detach(pid)
    wait_until_ready #if options[:wait_ready]
  end

  def wait_until_ready(ttl = 30)
    past = 0
    while past < ttl 
      break if check_ready
      sleep 1
      past += 1
      printf "\rWaiting pg ready: #{past} seconds"
    end
    puts
  end

  def check_ready
    system "#{@pg_isready_path} -h #{host} -p #{port} > /dev/null"
  end

  def setup_init_user()
    shell_out "#{@createuser_path} -s -p #{port} -l #{user} -w"
  end

  def setup_init_database()
    shell_out "#{@createdb_path} -p #{port} #{dbname} -O #{user}"
  end

  def cleanup()
    shell_out "#{@pgctl_path} stop -m fast -o '-p #{port}' -D #{data_dir}"
    remove_data_dir
  end
  alias_method :teardown, :cleanup

  def remove_data_dir()
    FileUtils.remove_dir(@data_dir)
  end

  private

  def shell_out(cmd)
    result = `#{cmd}`
    result.strip
  end
end
