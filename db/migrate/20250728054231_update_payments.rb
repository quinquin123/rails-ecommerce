
class UpdatePayments < ActiveRecord::Migration[7.1]
  def change
    add_column :payments, :payment_method, :string
    add_column :payments, :processed_at, :datetime
    add_column :payments, :failure_reason, :text
    
    add_index :payments, :status
    add_index :payments, :processed_at
  end
end