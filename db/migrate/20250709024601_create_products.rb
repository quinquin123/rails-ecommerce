class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products, id: :uuid do |t|
      t.references :seller, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.string :title
      t.text :description
      t.decimal :price, precision: 10, scale: 2
      t.references :category, type: :uuid, null: false, foreign_key: true
      t.text :tags, array: true, default: []
      t.string :status, default: 'moderated'
      t.string :preview_url
      t.string :download_url
      t.decimal :average_rating, precision: 3, scale: 1
      t.integer :reviews_count, default: 0

      t.timestamps
    end
  end
end
