# frozen_string_literal: true

class AddPublishedAtToProposals < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_proposals_proposals, :published_at, :datetime
  end
end
