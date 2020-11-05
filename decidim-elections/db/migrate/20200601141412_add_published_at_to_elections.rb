# frozen_string_literal: true

class AddPublishedAtToElections < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_elections_elections, :published_at, :datetime
  end
end
