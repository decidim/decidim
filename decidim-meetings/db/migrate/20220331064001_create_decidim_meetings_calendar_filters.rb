# frozen_string_literal: true

class CreateDecidimMeetingsCalendarFilters < ActiveRecord::Migration[6.1]
  def change
    create_table :decidim_meetings_calendar_filters do |t|
      t.uuid :identifier
      t.references :decidim_component, null: true, index: true
      t.jsonb :filters
      t.timestamps
    end
  end
end
