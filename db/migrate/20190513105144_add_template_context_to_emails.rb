class AddTemplateContextToEmails < ActiveRecord::Migration[5.2]
  def change
    add_column :emails, :template_context, :json, null: true
  end
end
