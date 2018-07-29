describe 'pg' do
  dbname = 'try'
  pg     = Dba::PgInstance.setup
  conn   = Dba::ConnectionBuilder.new(pg.conn_hash)
  `dbmigrate initdb #{dbname} --adminurl #{conn.url}`
  tconn  = conn.fork(dbanme: dbname)
  `dbmigrate up #{dbname} #{tconn.url}` 
  `dbmigrate seed #{dbname} #{tconn.url}` 
  db     = tconn.sequel_db

  before(:all) do
    # nothing
  end

  after(:all) do
    pg.teardown
  end

  context 'dump' do
    it 'work' do
      expect(db[:users].count).to eq 1
    end
  end
end
