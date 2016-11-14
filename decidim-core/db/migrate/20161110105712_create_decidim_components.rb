class CreateDecidimComponents < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_components do |t|
      t.references :decidim_participatory_process, foreign_key: true
      t.hstore :configuration
      t.string :component_type

      t.timestamps
    end
  end
end
