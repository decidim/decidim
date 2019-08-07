# frozen_string_literal: true

class AddPublishedAtToProposals < ActiveRecord::Migration[5.1]
  def up
    add_column :decidim_proposals_proposals, :published_at, :datetime, index: true
    # rubocop:disable Rails/SkipsModelValidations
    Decidim::Proposals::Proposal.update_all("published_at = updated_at")
    # rubocop:enable Rails/SkipsModelValidations
  end

  def down
    remove_column :decidim_proposals_proposals, :published_at
  end
end
