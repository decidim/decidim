# frozen_string_literal: true

class AddPublishedAtToProposals < ActiveRecord::Migration[5.1]
  def up
    add_column :decidim_proposals_proposals, :published_at, :datetime, index: true
    Decidim::Proposals::Proposal.find_each do |proposal|
      proposal.update_attributes!(published_at: proposal.updated_at)
    end
  end

  def down
    remove_column :decidim_proposals_proposals, :published_at
  end
end
