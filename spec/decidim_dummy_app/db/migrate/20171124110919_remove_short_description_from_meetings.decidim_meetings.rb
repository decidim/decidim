# This migration comes from decidim_meetings (originally 20170129153716)
# frozen_string_literal: true

class RemoveShortDescriptionFromMeetings < ActiveRecord::Migration[5.0]
  def change
    remove_column :decidim_meetings_meetings, :short_description
  end
end
