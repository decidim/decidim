class CreateDecidimAdminNavbarLinks < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_admin_navbar_links do |t|
      t.references :decidim_organization
      t.string :title
      t.string :link

      t.timestamps
    end
  end
end
