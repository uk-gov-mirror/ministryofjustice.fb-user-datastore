class RemoveUserReferenceFromUserData < ActiveRecord::Migration[5.2]
  def change
    rename_column :user_data, :user_id, :user_identifier
  end
end
