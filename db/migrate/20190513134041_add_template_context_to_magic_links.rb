class AddTemplateContextToMagicLinks < ActiveRecord::Migration[5.2]
  def change
    add_column :magic_links, :template_context, :json, null: true
  end
end
