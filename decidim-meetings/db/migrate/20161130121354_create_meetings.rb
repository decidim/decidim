class CreateMeetings < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_meetings_meetings do |t|
      t.jsonb :title
      t.jsonb :description
      t.jsonb :short_description
      t.datetime :start_date
      t.datetime :end_date
      t.text :address
      t.jsonb :location_hints
      t.references :decidim_component
      t.references :decidim_participatory_process_step,
                   index: { name: "decidim_component_step_meeting" }

      t.timestamps
    end
  end
end
