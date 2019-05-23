class RemoveColumns < ActiveRecord::Migration[5.2]
  def change
    remove_column :emails, :email, :text
    remove_column :emails, :validation_url, :text
    remove_column :emails, :template_context, :json

    remove_column :magic_links, :email, :text
    remove_column :magic_links, :validation_url, :text
    remove_column :magic_links, :template_context, :text
  end
end
