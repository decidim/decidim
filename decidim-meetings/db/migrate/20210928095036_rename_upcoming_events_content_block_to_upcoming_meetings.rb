# frozen_string_literal: true

class RenameUpcomingEventsContentBlockToUpcomingMeetings < ActiveRecord::Migration[6.0]
  class ContentBlock < ApplicationRecord
    self.table_name = :decidim_content_blocks
  end

  def change
    # rubocop:disable Rails/SkipsModelValidations
    ContentBlock.where(manifest_name: "upcoming_events").update_all(manifest_name: "upcoming_meetings")
    # rubocop:enable Rails/SkipsModelValidations
  end
end
