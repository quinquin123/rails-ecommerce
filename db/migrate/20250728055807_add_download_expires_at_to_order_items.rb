class AddDownloadExpiresAtToOrderItems < ActiveRecord::Migration[7.1]
  def change
    add_column :order_items, :download_expires_at, :datetime
  end
end
