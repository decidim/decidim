# frozen_string_literal: true

# By default all existing meetings were published when created
# This migration prevents un-publishing all existing meetings
class UpdatePublishedAtToExistingMeetings < ActiveRecord::Migration[5.2]
  def change
    Decidim::Meetings::Meeting.find_each do |meeting|
      if meeting.published_at.nil?
        # rubocop:disable Rails/SkipsModelValidations
        # use update_column to prevent running callbacks
        meeting.update_column :published_at, meeting.created_at
        # rubocop:enable Rails/SkipsModelValidations
      end
    end
  end
end
