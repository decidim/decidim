# frozen_string_literal: true

class AddPublishedAtToDecidimVotingsVotings < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_votings_votings, :published_at, :datetime
  end
end
