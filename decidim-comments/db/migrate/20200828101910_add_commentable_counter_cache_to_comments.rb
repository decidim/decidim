# frozen_string_literal: true

class AddCommentableCounterCacheToComments < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_comments_comments, :comments_count, :integer, null: false, default: 0, index: true
    Decidim::Comments::Comment.reset_column_information
    Decidim::Comments::Comment.find_each(&:update_comments_count)
  end
end
