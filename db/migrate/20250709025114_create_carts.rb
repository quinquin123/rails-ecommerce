class CreateCarts < ActiveRecord::Migration[7.1]
  def change
    create_table :carts, id: :uuid do |t|
      t.references :buyer, type: :uuid, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
