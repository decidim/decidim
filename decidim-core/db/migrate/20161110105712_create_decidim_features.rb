class CreateDecidimFeatures < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_features do |t|
      t.string :feature_type
      t.jsonb :name
      t.references :decidim_participatory_process
    end

    create_table :decidim_components do |t|
      t.jsonb :name
      t.jsonb :configuration
      t.string :component_type
      t.references :decidim_feature
      t.references :decidim_participatory_process_step,
                   index: { name: :component_step }

      t.timestamps
    end
  end
end
