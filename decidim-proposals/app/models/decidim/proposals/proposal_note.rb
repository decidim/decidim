# frozen_string_literal: true

module Decidim
  module Proposals
    # A proposal can include a notes created by admins.
    class ProposalNote < ApplicationRecord
      belongs_to :proposal, foreign_key: "decidim_proposal_id", class_name: "Decidim::Proposals::Proposal", counter_cache: true
      belongs_to :author, foreign_key: "decidim_author_id", class_name: "Decidim::User"
    end
  end
end
