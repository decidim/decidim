# frozen_string_literal: true

class FixAnsweredProposalsAfterCopy < ActiveRecord::Migration[5.2]
  def change
    proposals_after_copy = Decidim::ResourceLink.where(from_type: "Decidim::Proposals::Proposal").pluck(:from_id)

    result = Decidim::Proposals::Proposal.where.not(state_published_at: nil).where(state: nil, id: proposals_after_copy)

    result.update_all(state_published_at: nil)
  end
end
