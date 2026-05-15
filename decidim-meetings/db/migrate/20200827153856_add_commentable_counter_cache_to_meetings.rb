# frozen_string_literal: true

class AddCommentableCounterCacheToMeetings < ActiveRecord::Migration[5.2]
  class Meeting < ApplicationRecord
    self.table_name = :decidim_meetings_meetings
    include Decidim::HasComponent
    include Decidim::Comments::CommentableWithComponent
  end

  def change
    add_column :decidim_meetings_meetings, :comments_count, :integer, null: false, default: 0
    Meeting.reset_column_information
    Meeting.unscoped.find_each(&:update_comments_count)
  end
end
