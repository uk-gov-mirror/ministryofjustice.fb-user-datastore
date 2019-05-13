class AddValidationUrlToEmails < ActiveRecord::Migration[5.2]
  def change
    add_column :emails, :validation_url, :text, null: false
  end
end
