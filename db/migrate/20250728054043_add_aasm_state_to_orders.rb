class AddAasmStateToOrders < ActiveRecord::Migration[7.1]
  def up
    add_column :orders, :aasm_state, :string, default: 'pending'
    add_index :orders, :aasm_state
    
    execute <<-SQL
      UPDATE orders SET aasm_state = status WHERE status IS NOT NULL
    SQL

  end
  
  def down
    remove_index :orders, :aasm_state
    remove_column :orders, :aasm_state
  end
end