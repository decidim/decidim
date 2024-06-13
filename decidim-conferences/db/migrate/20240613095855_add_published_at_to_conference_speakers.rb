# frozen_string_literal: true

class AddPublishedAtToConferenceSpeakers < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_conference_speakers, :published_at, :datetime, index: true
  end
end
