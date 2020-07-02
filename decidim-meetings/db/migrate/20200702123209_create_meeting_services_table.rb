# frozen_string_literal: true

class CreateMeetingServicesTable < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_meetings_services do |t|
      t.jsonb :title
      t.jsonb :description
      t.bigint :decidim_meeting_id, null: false, index: true

      t.timestamps
    end
  end
end
