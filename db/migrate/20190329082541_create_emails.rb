class CreateEmails < ActiveRecord::Migration[5.2]
  def change
    create_table :emails, id: :uuid do |t|
      t.uuid :unique_id
      t.string :email
      t.string :service_slug
      t.string :encrypted_payload
      t.datetime :expires_at

      t.timestamps
    end
  end
end
