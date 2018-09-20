class AddUserData < ActiveRecord::Migration[5.2]
  def change
    create_table :user_data, id: :uuid do |t|
      t.uuid            :user_id
      t.string          :payload
      t.timestamps
    end
  end
end
