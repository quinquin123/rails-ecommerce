class CreateProductImports < ActiveRecord::Migration[7.1]
  def change
    create_table :product_imports, id: :uuid do |t|
      t.references :seller, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.string :file_name
      t.string :status, default: 'pending'
      t.text :error_messages, array: true, default: []
      t.integer :processed_count, default: 0
      t.integer :failed_count, default: 0

      t.timestamps
    end
  end
end
