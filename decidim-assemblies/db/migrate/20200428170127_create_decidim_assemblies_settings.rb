class CreateDecidimAssembliesSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_assemblies_settings do |t|
      t.boolean :enable_organization_chart, null: false
      t.references :decidim_organization, foreign_key: true      
      t.timestamps
    end
  end
end
