class CreateDecidimPages < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_pages_pages do |t|
      t.jsonb :title
      t.jsonb :body
      t.references :decidim_component
      t.references :decidim_participatory_process_step,
                   index: { name: "decidim_component_step" }

      t.timestamps
    end
  end
end
