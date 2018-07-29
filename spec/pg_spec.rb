describe Dba::PgInstance do
  pg = described_class.new

  before(:all) do
    pg.setup
  end

  after(:all) do
    pg.teardown
  end

  context 'setup workflow' do
    it 'options works' do
      expect(pg.conn_hash).to eq(described_class::DEFAULT_CONN_HASH)
    end
  end

  context 'run sql' do
    conn = Dba::ConnectionBuilder.new(pg.conn_hash)

    it 'options ok' do
      %w(scheme host port dbname).each do |k|
        expect(conn.send(k)).to eq(pg.send(k))
      end
    end

    it 'create user' do
      user = 'DummyUser'
      conn.run_sql "create role #{user} with login password 'test123';"
      result = conn.run_sql "select usename from pg_catalog.pg_user;"
      # 注意： 用户是大小写敏感的！
      expect(result.values).to include([user.downcase])
      conn.run_sql "drop role #{user};"
      result = conn.run_sql "select usename from pg_catalog.pg_user;"
      expect(result.values).to_not include([user.downcase])
    end

    it 'create database' do
      dbname = "test#{Time.now.to_i}"
      conn.run_sql "create database #{dbname};"
      result = conn.run_sql "select datname from pg_catalog.pg_database;"
      expect(result.values).to include([dbname])
      conn.run_sql "drop database #{dbname};"
      result = conn.run_sql "select datname from pg_catalog.pg_database;"
      expect(result.values).to_not include([dbname])
    end
  end
end

__END__

The PUBLIC role
• An implicit group everybody belongs to
• Has some default rights granted
