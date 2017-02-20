class AddOrganizationCustomReference < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_organizations, :custom_reference, :string, null: false
  end
end
