describe "Try db" do
  dbname = 'try'
  pg     = Dba::PgInstance.setup
  conn   = Dba::ConnectionBuilder.new(pg.conn_hash)
  `dbmigrate initdb #{dbname} --adminurl #{conn.url}`
  tconn  = conn.fork(dbanme: dbname)
  `dbmigrate up #{dbname} #{tconn.url}` 
  db     = Sequel.connect(tconn.url)

  before(:all) do
    # nothing
  end

  after(:all) do
    if ENV['DEBUG']
      system "dbmigrate dump #{tconn.url}"
      #conn.cli(runner: :psql)
      byebug 
    end
    pg.teardown
  end

  context 'users' do
    it 'can create user' do
      db[:users].insert(name: 'geek')
      expect(db.from(:users).count).to eq 1
    end
  end
end
