# frozen_string_literal: true

class RenameEventsToMeetings < ActiveRecord::Migration[6.0]
  def change
    Decidim::ContentBlock.where(manifest_name: :upcoming_events).find_each do |block|
      block.manifest_name = "upcoming_meetings"
      block.save
    end
  end
end
