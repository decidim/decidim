class CreateDecidimAssembliesSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_assemblies_settings do |t|
      t.boolean :enable_organization_chart
      t.references :decidim_organization, foreign_key: true
    end
  end
end
