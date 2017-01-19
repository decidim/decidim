class AddShowStatisticsToOrganization < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_organizations, :show_statistics, :boolean, default: false
  end 
end
