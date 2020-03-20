# frozen_string_literal: true

class IndexForeignKeysInDecidimBlogsPosts < ActiveRecord::Migration[5.2]
  def change
    add_index :decidim_blogs_posts, :decidim_user_group_id
  end
end
