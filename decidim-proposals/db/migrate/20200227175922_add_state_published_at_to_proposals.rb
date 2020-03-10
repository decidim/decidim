# frozen_string_literal: true

class AddStatePublishedAtToProposals < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_proposals_proposals, :state_published_at, :datetime
  end
end
