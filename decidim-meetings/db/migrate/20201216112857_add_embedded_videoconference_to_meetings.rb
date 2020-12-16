# frozen_string_literal: true

class AddEmbeddedVideoconferenceToMeetings < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_meetings_meetings, :embedded_videoconference, :boolean, default: false
  end
end
