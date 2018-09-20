class AddUserDataIndices < ActiveRecord::Migration[5.2]
  def change
    add_index :user_data, [:service_slug, :user_id], unique: true
  end
end
