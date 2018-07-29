require 'sequel'
require_relative 'sequel_postgres_schemata'
#db = Sequel.connect aurl, search_path: %w(foo public) 

# extend
module Sequel::Postgres::Schemata::DatabaseMethods
  def user_schemata
    # system schema, public as default
    sys_schemas = [:pg_toast, :pg_temp_1, :pg_toast_temp_1, 
                   :pg_catalog, :information_schema] 
    (schemata - sys_schemas).delete_if{|i| i.to_s =~ /^pg/ }
  end
end
