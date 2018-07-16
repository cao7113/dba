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

  context 'run sql' do
    conn = Dba::ConnBuilder.new(pg.conn_hash)

    it 'options ok' do
      %w(scheme host port dbname).each do |k|
        expect(conn.send(k)).to eq(pg.send(k))
      end
    end
  end
end
