# frozen_string_literal: true

# By default all existing meetings were published when created
# This migration prevents un-publishing all existing meetings
class UpdatePublishedAtToExistingMeetings < ActiveRecord::Migration[5.2]
  class Meeting < ApplicationRecord
    self.table_name = :decidim_meetings_meetings
  end

  def change
    Meeting.reset_column_information

    Meeting.find_each do |meeting|
      if meeting.published_at.nil?
        meeting.published_at = meeting.created_at
        meeting.save!
      end
    end
  end
end
