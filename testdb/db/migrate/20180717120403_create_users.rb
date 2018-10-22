Sequel.migration do
  up do
    create_table(:users) do
      primary_key :id
      String :name, null: false
      String :email, limit: 50
      String :wechat
      String :mobile
      Date   :birthday
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP, :index=>true
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end

  down do
    drop_table(:users)
  end
end
