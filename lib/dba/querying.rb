require_relative '../ext/sequel'

module Dba::Querying
  def sequel_db
    return @sdb if @sdb
    @sdb = Sequel.connect(self.url)
    @sdb.search_path = @sdb.user_schemata
    @sdb
  end
  alias_method :sdb, :sequel_db

  def dbsize(db = nil)
    db ||= self.dbname
    @_size ||= run_sql("select pg_database_size('#{db}')").values.first[0].to_i
  rescue =>e
    nil
  end

  def table_count(table)
    if table.respond_to?(:include?) && table.include?('.')
      # public.user
      table = Sequel.qualify(*table.split('.'))
    end
    sequel_db.from(table).count
  end

  # todo master_fork
  # ref rails ActiveRecord create database
  def databases
    # for pg
    fork(dbname: 'postgres') do |c|
      r = c.run_sql 'select datname from pg_database' 
      r.values
    end
  end
end
