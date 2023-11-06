# frozen_string_literal: true

class AddPublishedAtToDecidimBlogsPosts < ActiveRecord::Migration[6.1]
  class Post < ApplicationRecord
    self.table_name = :decidim_blogs_posts
  end

  def change
    add_column :decidim_blogs_posts, :published_at, :datetime

    reversible do |direction|
      direction.up do
        Post.update_all("published_at = created_at") # rubocop:disable Rails/SkipsModelValidations
      end
    end
  end
end
