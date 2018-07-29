# http://sequel.jeremyevans.net/rdoc/files/doc/schema_modification_rdoc.html
Sequel.migration do
  up do
    # extension :pg_enum
    create_table(:blogs) do
      primary_key :id
      String  :title, null: false
      Integer :user_id
      String  :content
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end

  down do
    drop_table(:blogs)
  end
end
