class CreateEmails < ActiveRecord::Migration[5.2]
  def change
    create_table :emails, id: :uuid do |t|
      t.string :email
      t.string :service_slug
      t.string :encrypted_payload
      t.datetime :expires_at
      t.string :validity

      t.timestamps
    end
  end
end
