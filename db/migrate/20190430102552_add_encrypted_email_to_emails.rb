class AddEncryptedEmailToEmails < ActiveRecord::Migration[5.2]
  def change
    add_column :emails, :encrypted_email, :text, null: false
  end
end
