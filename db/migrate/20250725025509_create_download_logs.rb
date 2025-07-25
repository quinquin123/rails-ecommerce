class CreateDownloadLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :download_logs do |t|
      t.uuid :user_id 
      t.references :product, type: :uuid, foreign_key: true
      t.string :ip_address
      t.string :user_agent
      t.datetime :downloaded_at

      t.timestamps
    end
    add_foreign_key :download_logs, :users, column: :user_id
  end
end
