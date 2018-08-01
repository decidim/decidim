# frozen_string_literal: true

Decidim::Proposals::ProposalVote.class_eval do
  def self.create_or_delete(proposal, current_user, weight)
    if where(author: current_user, proposal: proposal, weight: weight).any?
      :delete
    else
      :post
    end
  end
end
