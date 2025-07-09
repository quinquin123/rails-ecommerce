class CreateOrderItems < ActiveRecord::Migration[7.1]
  def change
    create_table :order_items, id: :uuid do |t|
      t.references :order, type: :uuid, null: false, foreign_key: true
      t.references :product, type: :uuid, null: false, foreign_key: true
      t.decimal :price_at_purchase, precision: 10, scale: 2
      t.string :download_url

      t.timestamps
    end
  end
end
