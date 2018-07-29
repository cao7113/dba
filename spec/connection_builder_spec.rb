describe Dba::ConnectionBuilder do
  context 'options' do
    it 'parsed ok' do
      url = 'postgres://dbauser@localhost:5432/abc'
      conn = described_class.new(url: url)
      expect(conn.dbname).to eq 'abc'
    end

    it 'check db not exist' do
      url = 'postgres://dbauser@localhost:5432/missing_db'
      conn = described_class.new(url: url)
      expect(conn.db_not_exist?).to be_truthy
    end
  end
end
