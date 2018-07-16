require 'byebug'
require_relative '../lib/dba'

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
    conn = Dba::ConnBuilder.new(pg.conn_hash)

    it 'options ok' do
      %w(scheme host port dbname).each do |k|
        expect(conn.send(k)).to eq(pg.send(k))
      end
    end

    it 'create user' do
      user = 'DummyUser'
      conn.sql "create role #{user} with login password 'test123';"
      result = conn.sql "select usename from pg_catalog.pg_user;"
      # 注意： 用户是大小写敏感的！
      expect(result.values).to include([user.downcase])
      conn.sql "drop role #{user};"
      result = conn.sql "select usename from pg_catalog.pg_user;"
      expect(result.values).to_not include([user.downcase])
    end

    it 'create database' do
      dbname = "test#{Time.now.to_i}"
      conn.sql "create database #{dbname};"
      result = conn.sql "select datname from pg_catalog.pg_database;"
      expect(result.values).to include([dbname])
      conn.sql "drop database #{dbname};"
      result = conn.sql "select datname from pg_catalog.pg_database;"
      expect(result.values).to_not include([dbname])
    end
  end
end
