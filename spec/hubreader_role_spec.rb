# * hubreader can run \du \l \d stat.* # see important info
# * try other ways: https://github.com/PostgREST/postgrest
def ops_sqls(dbauser: , dbname: , hubrole: , hubuser: , passwd: )
  <<-SQL
    create role #{hubrole};
    create user #{hubuser} with encrypted password '#{passwd}' in role #{hubrole};

    REVOKE ALL ON DATABASE #{dbname} FROM PUBLIC;
    -- without below: #{hubrole} can create table in public schema!!?
    REVOKE ALL ON schema public FROM public;

    GRANT CONNECT ON DATABASE #{dbname} TO #{hubrole};
    -- must have usage on schema to select in table
    GRANT USAGE ON schema data TO #{hubrole};
    GRANT SELECT ON ALL TABLES IN SCHEMA data to #{hubrole};
    -- can access new created tables for the user
    ALTER DEFAULT PRIVILEGES FOR USER #{dbauser} IN SCHEMA data GRANT SELECT, USAGE ON SEQUENCES TO #{hubrole};
    ALTER DEFAULT PRIVILEGES FOR USER #{dbauser} IN SCHEMA data GRANT SELECT ON TABLES TO #{hubrole};

    -- ALTER USER #{hubuser} SET search_path=data;
  SQL
end

def rand_tbl
  "tbl#{Time.now.to_i}rand#{rand(1000)}"
end

describe 'pg hubreader role' do
  dbauser   = 'dbauser'
  dbname    = 'optimus'
  hreader   = 'hubreader'
  arrowsbot = 'arrowshubbot1' 
  pg        = Dba::PgInstance.new
  conn      = Dba::ConnectionBuilder.new(pg.conn_hash)

  before(:all) do
    pg.setup

    ####################################################
    #             Mock DB Environment
    # roles
    conn.run_sql <<-SQL
      create user #{dbauser} with superuser encrypted password 'test';
    SQL

    # dbs
    dbs = <<-SQL
      create database blogs;
      create database #{dbname} with owner #{dbauser}; 
      create database cms with owner #{dbauser};
    SQL
    # CREATE DATABASE cannot be executed inside a transaction block. by mannual!
    dbs.split("\n").each do |sql|
      conn.run_sql sql
    end

    # prepare structure
    conn.fork dbname: 'blogs' do |c|
      c.run_sql "create table posts (id int, title varchar);"
    end
    conn.fork dbname: 'cms', user: dbauser do |c|
      c.run_sql <<-SQL
        create table articles (id int, title varchar);
        create schema data;
        create table data.comments (id int, content text);
      SQL
    end

    # main db schemas
    dba_conn = conn.fork user: dbauser, dbname: dbname
    dba_conn.run_sql <<-SQL
      create table investors (id int, name varchar);
      create schema data;
      create table data.hub_products (id int, name varchar);
      create schema stat;
      create table stat.hot_tags (id int, name varchar);
    SQL

    ######################################################
    #             Add hubreader role

    sqls = ops_sqls(dbauser: dbauser, dbname: dbname, hubrole: hreader, hubuser: arrowsbot, passwd: 'test123')
    dba_conn.run_sql sqls

    dba_conn.run_sql <<-SQL
      -- list all? deny public role access
      REVOKE ALL ON DATABASE cms FROM PUBLIC;
      REVOKE ALL ON DATABASE blogs FROM PUBLIC;
    SQL
  end

  after(:all) do
    ## clear role
    conn.run_sql <<-SQL
      drop user #{arrowsbot};
      create role bot1;
      reassign owned by #{hreader} to bot1;
    SQL
    conn.fork(user: dbauser, dbname: dbname) do |c|
      c.run_sql <<-SQL
        drop owned by #{hreader};
        drop role #{hreader};
        drop role bot1;
      SQL
    end
    #byebug # conn.cli

    pg.teardown

    #puts '=' * 30
    #puts "for local"
    #puts ops_sqls(dbauser: dbauser, dbname: 'starup1', hubrole: hreader, hubuser: arrowsbot, passwd: 'test123')
  end

  context "user setup" do
    it 'ready' do
      result = conn.run_sql "select usename from pg_catalog.pg_user;"
      expect(result.values).to include([dbauser])
      expect(result.values).to include([arrowsbot])
    end
  end

  context 'arrows in optimus db' do
    opts = { user: arrowsbot, dbname: dbname }
    it 'can read data.* tables' do
      result = conn.fork(opts).run_sql('select count(*) from data.hub_products')
      expect(result.allowed?).to be_truthy
    end

    it 'can read new created data.* table' do
      tbl = "data.#{rand_tbl}"
      conn.fork(opts.merge(user: dbauser)).run_sql("create table #{tbl} (id int);")
      result = conn.fork(opts).run_sql("select count(*) from #{tbl}")
      expect(result.allowed?).to be_truthy
    end

    it 'cannot create public.* table' do
      result = conn.fork(opts).run_sql("create table public.#{rand_tbl} (id int);")
      expect(result.denied?).to be_truthy
    end

    it 'cannot read new created public.* table' do
      tbl = "public.#{rand_tbl}"
      conn.fork(opts.merge(user: dbauser)).run_sql("create table #{tbl} (id int);")
      result = conn.fork(opts).run_sql("select count(*) from #{tbl}")
      expect(result.denied?).to be_truthy
    end

    it 'cannot visit stat.* talbe' do
      result = conn.fork(opts).run_sql("select count(*) from stat.hot_tags;")
      expect(result.denied?).to be_truthy
    end
  end

  context 'arrows in cms db' do
    opts = { user: arrowsbot, dbname: 'cms' }

    it 'cannot read table' do
      result = conn.fork(opts).run_sql('select count(*) from public.articles')
      expect(result.denied?).to be_truthy
    end

    it 'cannot create table' do
      result = conn.fork(opts).run_sql("create table public.#{rand_tbl} (id int);")
      expect(result.denied?).to be_truthy
    end

    it 'cannot read data.* table' do
      result = conn.fork(opts).run_sql('select count(*) from data.comments')
      expect(result.denied?).to be_truthy
    end
  end

  context 'arrows in blogs db' do
    opts = { user: arrowsbot, dbname: 'blogs' }

    it 'cannot read table' do
      result = conn.fork(opts).run_sql('select count(*) from public.posts')
      expect(result.denied?).to be_truthy
    end
  end

  context 'donot affect dbauser rights' do
    opts = { user: dbauser, dbname: dbname }

    it 'can create public.* table in optimus db' do
      result = conn.fork(opts).run_sql("create table public.#{rand_tbl} (id int);")
      expect(result.allowed?).to be_truthy
    end

    it 'can read multiple schemas table in optimus db' do
      result = conn.fork(opts).run_sql('select count(*) from data.hub_products')
      expect(result.allowed?).to be_truthy
      result = conn.fork(opts).run_sql('select count(*) from stat.hot_tags')
      expect(result.allowed?).to be_truthy
    end
  end

  context 'new created db' do newdb = "db#{Time.now.to_i}rand#{rand(1000)}"
    before(:all) do
      conn.fork(user: dbauser).run_sql "create database #{newdb};"
      conn.fork(user: dbauser, dbname: newdb).run_sql <<-SQL
        create table t1 (id int);
        create schema data;
        create table data.t2 (id int);
      SQL
    end
    opts = {user: arrowsbot, dbname: newdb}

    it 'works to dbauser' do
      result = conn.fork(opts.merge(user: dbauser)).run_sql "select * from t1;"
      expect(result.allowed?).to be_truthy
    end

    it 'works' do
      result = conn.fork(opts).run_sql "select * from public.t1;"
      expect(result.allowed?).to be_falsey
      result = conn.fork(opts).run_sql "select * from data.t2;"
      expect(result.allowed?).to be_falsey
    end

    # todo still can create table in new db public schema!!!
  end
end
