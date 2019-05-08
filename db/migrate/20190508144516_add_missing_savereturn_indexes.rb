class AddMissingSavereturnIndexes < ActiveRecord::Migration[5.2]
  def change
    add_index :emails, [:service_slug, :encrypted_email]
    remove_index :magic_links, [:encrypted_email]
    add_index :magic_links, [:service_slug, :encrypted_email]
  end
end
