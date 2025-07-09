class CreateCartItems < ActiveRecord::Migration[7.1]
  def change
    create_table :cart_items, id: :uuid do |t|
      t.references :cart, type: :uuid, null: false, foreign_key: true
      t.references :product, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
