class Dba::ScriptRunner
  attr_accessor :conn

  def initialize(conn)
    @conn = conn
  end

  def get_binding
    binding
  end

  def sequel_db
    conn.sequel_db
  end
end
