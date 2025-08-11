class CreateQuynhSchema < ActiveRecord::Migration[7.1]
  def up 
    execute "CREATE SCHEMA IF NOT EXISTS quynh_schema"
  end

  def down
    execute "DROP SCHEMA IF EXISTS quynh_schema CASCADE"
  end
end
