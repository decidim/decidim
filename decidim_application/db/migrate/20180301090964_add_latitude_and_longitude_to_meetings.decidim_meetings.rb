# This migration comes from decidim_meetings (originally 20170123151650)
# frozen_string_literal: true

class AddLatitudeAndLongitudeToMeetings < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_meetings_meetings, :latitude, :float
    add_column :decidim_meetings_meetings, :longitude, :float
  end
end
