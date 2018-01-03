# This migration comes from decidim (originally 20170206142116)
# frozen_string_literal: true

class AddPublishedAtToDecidimFeatures < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_features, :published_at, :datetime
    execute "UPDATE decidim_features SET published_at=#{quote(Time.current)}"
  end
end
