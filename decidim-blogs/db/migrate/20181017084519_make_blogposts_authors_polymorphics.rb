# frozen_string_literal: true

class MakeBlogpostsAuthorsPolymorphics < ActiveRecord::Migration[5.2]
  class Post < ApplicationRecord
    self.table_name = :decidim_blogs_posts

    include Decidim::HasComponent
  end

  def change
    add_column :decidim_blogs_posts, :decidim_author_type, :string

    Post.reset_column_information
    Post.find_each do |post|
      if post.decidim_author_id.present?
        post.decidim_author_type = "Decidim::UserBaseEntity"
      else
        post.decidim_author_id = post.organization.id
        post.decidim_author_type = "Decidim::Organization"
      end
      post.save!
    end

    add_index :decidim_blogs_posts,
              [:decidim_author_id, :decidim_author_type],
              name: "index_decidim_blogs_posts_on_decidim_author"
    change_column_null :decidim_blogs_posts, :decidim_author_id, false
    change_column_null :decidim_blogs_posts, :decidim_author_type, false

    Post.reset_column_information
  end
end
