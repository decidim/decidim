# frozen_string_literal: true

class AddOrganizerToMeetings < ActiveRecord::Migration[5.1]
  def change
    add_reference :decidim_meetings_meetings, :organizer, index: true
  end
end
