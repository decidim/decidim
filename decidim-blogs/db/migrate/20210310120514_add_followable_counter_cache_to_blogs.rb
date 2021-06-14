# frozen_string_literal: true

class AddFollowableCounterCacheToBlogs < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_blogs_posts, :follows_count, :integer, null: false, default: 0, index: true

    reversible do |dir|
      dir.up do
        Decidim::Blogs::Post.reset_column_information
        Decidim::Blogs::Post.find_each do |record|
          record.class.reset_counters(record.id, :follows)
        end
      end
    end
  end
end
