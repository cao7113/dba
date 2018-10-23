require 'yaml'

module Dba 
  class << self
    def lib_path
      Pathname(__dir__)
    end

    def dba_root
      lib_path.parent
    end
  end
end

require_relative 'dba/util'
require_relative 'dba/script_runner'
require_relative 'dba/connection_builder'
require_relative 'dba/pg_instance'

module Dba
  class << self
    def load_dbs!(fpath)
      dbs = {}
      unless fpath.exist?
        warn "No file: #{fpath.to_s}!" 
        return dbs
      end
      hash = YAML.load_file(fpath)
      hash.each do |g, items|
        gprekey = '_group_prefix'
        gpre = items.key?(gprekey) ? items.delete(gprekey) : g
        gpre = nil if gpre =~ /^\s+$/
        items.each do |name, opts|
          ids = [gpre]
          unless gpre && name.to_s == 'default'
            ids << name
          end
          conn_builder = ConnectionBuilder.new(opts)
          conn_builder.connid = ids.compact.join('_')
          dbs[conn_builder.connid] = conn_builder
        end
      end
      dbs
    end

    def pg
      @_conn ||= PgInstance.new
    end

    def conn(url = 'postgres://localhost/try')
      @_conn ||= ConnectionBuilder.new(url: url)
    end
  end

  # open class
  class PgInstance
    def conn
      @_conn ||= ConnectionBuilder.new(self.conn_hash)
    end
  end
end

dbsfile = ENV['DBSFILE'] || '~/.dbs.yml'
fpath = Pathname(dbsfile).expand_path
$dbs = Dba.load_dbs!(fpath)
