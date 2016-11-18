class AddLocalesSettings < ActiveRecord::Migration[5.0]
  def up
    add_column :decidim_organizations, :available_locales, :string, array: true, default: []
    add_column :decidim_organizations, :default_locale, :string

    Decidim::Organization.update_all(available_locales: Decidim.available_locales)
  end

  def down
    remove_column :decidim_organizations, :available_locales
    remove_column :decidim_organizations, :default_locale
  end
end
