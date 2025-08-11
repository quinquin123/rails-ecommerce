class CreateUsersInQuynhSchema < ActiveRecord::Migration[7.1]
  def change
    create_table "quynh_schema.users" do |t|
      t.string :name
      t.string :email

      t.timestamps
    end
  end
end
