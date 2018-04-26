# frozen_string_literal: true

class CreateDecidimBlogsPosts < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_blogs_posts do |t|
      t.jsonb :title
      t.jsonb :body
      t.references :decidim_component, index: true
      t.timestamps
    end
  end
end
