class AddDescriptionToOrganizations < ActiveRecord::Migration[5.0]
  def change
    enable_extension :hstore

    change_table :decidim_organizations do |t|
      t.hstore :description
    end
  end
end
