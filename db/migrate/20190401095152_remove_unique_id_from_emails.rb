class RemoveUniqueIdFromEmails < ActiveRecord::Migration[5.2]
  def change
    remove_column :emails, :unique_id
  end
end
