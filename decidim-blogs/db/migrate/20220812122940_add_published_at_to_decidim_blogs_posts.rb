class AddPublishedAtToDecidimBlogsPosts < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_blogs_posts, :published_at, :datetime
  end
end
