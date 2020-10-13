# frozen_string_literal: true

class AddCommentableCounterCacheToPosts < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_blogs_posts, :comments_count, :integer, null: false, default: 0, index: true
    Decidim::Blogs::Post.reset_column_information
    Decidim::Blogs::Post.find_each(&:update_comments_count)
  end
end
