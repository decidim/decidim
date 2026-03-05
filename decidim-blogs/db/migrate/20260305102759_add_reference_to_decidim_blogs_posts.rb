# frozen_string_literal: true

class AddReferenceToDecidimBlogsPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :decidim_blogs_posts, :reference, :string
  end
end
