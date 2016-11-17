class AddParticipatoryProcessSteps < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_participatory_process_steps do |t|
      t.jsonb :title, null: false
      t.jsonb :short_description, null: false
      t.jsonb :description, null: false
      t.datetime :start_date
      t.datetime :end_date
      t.references :decidim_participatory_process,
        foreign_key: true,
        index: { name: 'index_decidim_processes_steps__on_decidim_process_id' }

      t.timestamps
    end
  end
end
