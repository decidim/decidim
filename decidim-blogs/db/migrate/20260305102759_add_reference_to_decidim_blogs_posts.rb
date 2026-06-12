# frozen_string_literal: true

class AddReferenceToDecidimBlogsPosts < ActiveRecord::Migration[8.0]
  class Post < ApplicationRecord
    self.table_name = :decidim_blogs_posts

    include Decidim::HasComponent
    include Decidim::HasReference
  end

  def change
    add_column :decidim_blogs_posts, :reference, :string
    Post.reset_column_information
    Post.find_each { |post| post.send(:store_reference) }
  end
end
