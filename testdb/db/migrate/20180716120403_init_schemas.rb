Sequel.migration do
  up do
    run <<-SQL
      create schema stats;
      create schema marketing;
    SQL
  end

  down do
    run <<-SQL
      drop schema marketing;
      drop schema stats;
    SQL
  end
end
