class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders, id: :uuid do |t|
      t.references :buyer, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.decimal :total_amount, precision: 10, scale: 2
      t.string :status, default: 'pending'

      t.timestamps
    end
  end
end
