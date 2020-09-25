# frozen_string_literal: true

class AddCommentableCounterCacheToResults < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_accountability_results, :comments_count, :integer, null: false, default: 0, index: true
    Decidim::Accountability::Result.reset_column_information
    Decidim::Accountability::Result.find_each(&:update_comments_count)
  end
end
