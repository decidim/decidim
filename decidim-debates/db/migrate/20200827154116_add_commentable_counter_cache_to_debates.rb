# frozen_string_literal: true

class AddCommentableCounterCacheToDebates < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_debates_debates, :comments_count, :integer, null: false, default: 0, index: true
    Decidim::Debates::Debate.reset_column_information
    Decidim::Debates::Debate.find_each(&:update_comments_count)
  end
end
