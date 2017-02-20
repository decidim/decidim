class AddOrganizationCustomReference < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_organizations, :reference_prefix, :string, null: false
  end
end
