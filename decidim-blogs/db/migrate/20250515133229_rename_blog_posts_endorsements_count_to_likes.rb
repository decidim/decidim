# frozen_string_literal: true

class RenameBlogPostsEndorsementsCountToLikes < ActiveRecord::Migration[7.0]
  def change
    rename_column :decidim_blogs_posts, :endorsements_count, :likes_count
  end
end
