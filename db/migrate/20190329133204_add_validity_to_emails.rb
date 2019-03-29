class AddValidityToEmails < ActiveRecord::Migration[5.2]
  def change
    add_column :emails, :validity, :string
  end
end
