describe "Pg Schema" do
  pg   = Dba::PgInstance.setup
  conn = Dba::ConnectionBuilder.new(pg.conn_hash)
  db   = Sequel.connect(conn.url, search_path: %w(public data))

  before(:all) do
    conn.run_sql <<-SQL
      create table users (id serial, name varchar);
      insert into users(name) values ('geek');

      create schema data;
      create table data.blogs (id serial, title varchar);
      insert into data.blogs(title) values ('hi pg schema');
      -- same name table
      create table data.users (id serial, name varchar);
      -- set search_path = 'data, public';
    SQL
  end

  after(:all) do
    pg.teardown
  end

  context 'support search_path' do
    it 'switch' do
      #db[:blogs].sql #"SELECT * FROM \"blogs\""
      dataset = db[Sequel.qualify(:data, :blogs)]
      expect(dataset.count).to eq(1)
      #byebug

      # db.tables           # [:users, :blogs, :users]
      # db.search_path      # [:public, :data]
      # db.current_schemata # [:public, :data]
      # db.schemata  #[:pg_toast, :pg_temp_1, :pg_toast_temp_1, :pg_catalog, :public, :information_schema, :data]
      expect(db[:users].count).to eq(1)
      #db.search_path :baz, prepend: true
      db.search_path :data do
        # db.search_path      # [:data]
        expect(db[:users].count).to eq(0)
      end
      # search_path 设置只影响当前连接
      # db.search_path      # [:public, :data]
      expect(db[:users].count).to eq(1)
      expect(db[Sequel.qualify(:public,:users)].count).to eq(1)
      expect(db[Sequel.qualify(:data,:users)].count).to eq(0)

      conn.exec "set search_path = 'data, public';"
      #byebug # conn.cli
      # 设置完search_path后表必须带schema
      r = conn.exec "select * from data.blogs;"
      expect(r.failed?).to be_falsey

      db.create_schema :bar
      expect(db.schemata[-1]).to eq(:bar) # at last
      #byebug
      expect(db.search_path).to eq([:public, :data])
    end
  end
end
