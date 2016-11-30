class CreateDecidimFeatures < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_features do |t|
      t.string :manifest_name
      t.jsonb :name
      t.references :decidim_participatory_process
    end
  end
end
