Sequel.migration do
  up do
    # extension :pg_enum
    create_table(:qurls) do
      primary_key :id
      String :url, null: false
      String :name
      String :group
      DateTime :created_at
    end
  end

  down do
    drop_table(:qurls)
  end
end
