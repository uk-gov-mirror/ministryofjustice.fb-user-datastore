class RenameServiceToServiceSlugs < ActiveRecord::Migration[5.2]
  def change
    rename_column :magic_links, :service, :service_slug
    rename_column :save_returns, :service, :service_slug
  end
end
