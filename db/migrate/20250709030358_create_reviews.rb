class CreateReviews < ActiveRecord::Migration[7.1]
  def change
    create_table :reviews, id: :uuid do |t|
      t.references :buyer, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.references :product, type: :uuid, null: false, foreign_key: true
      t.references :order, type: :uuid, null: false, foreign_key: true
      t.integer :rating
      t.text :comment

      t.timestamps
    end
    add_index :reviews, [:buyer_id, :product_id], unique: true
  end
end
