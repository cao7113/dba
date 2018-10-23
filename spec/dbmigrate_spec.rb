describe 'dbmigrate' do
  Dir.chdir Dba.dba_root.join('testdb')
  dbname = 'testdb'
  pg     = Dba::PgInstance.setup
  conn   = Dba::ConnectionBuilder.new(pg.conn_hash)
  `dbmigrate initdb #{dbname} --adminurl #{conn.url}`
  tconn  = conn.fork(dbanme: dbname)
  `dbmigrate up #{tconn.url}` 
  `dbmigrate seed #{tconn.url}` 
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
