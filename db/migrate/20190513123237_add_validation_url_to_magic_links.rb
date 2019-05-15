class AddValidationUrlToMagicLinks < ActiveRecord::Migration[5.2]
  def change
    add_column :magic_links, :validation_url, :text, null: false
  end
end
