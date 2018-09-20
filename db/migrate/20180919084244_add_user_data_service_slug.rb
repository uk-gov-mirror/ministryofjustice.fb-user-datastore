class AddUserDataServiceSlug < ActiveRecord::Migration[5.2]
  def change
    add_column :user_data, :service_slug, :string
  end
end
