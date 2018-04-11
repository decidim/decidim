# frozen_string_literal: true

class AddMeetingTypes < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_meetings_meetings, :is_private, :boolean, default: false
    add_column :decidim_meetings_meetings, :is_transparent, :boolean, default: true
  end
end
