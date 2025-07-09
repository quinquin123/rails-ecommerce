class CreatePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :payments, id: :uuid do |t|
      t.references :order, type: :uuid, null: false, foreign_key: true
      t.string :status, default: 'failed'

      t.timestamps
    end
  end
end
