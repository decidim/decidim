# frozen_string_literal: true

module Decidim
  module Proposals
    # Compatibility model for migrations written before ProposalState was
    # renamed to ProposalStatus. It points at the pre-rename table names.
    class ProposalState < ApplicationRecord
      include Decidim::Traceable

      self.table_name = :decidim_proposals_proposal_states

      belongs_to :component,
                 class_name: "Decidim::Component",
                 foreign_key: "decidim_component_id",
                 inverse_of: false

      has_many :proposals,
               class_name: "Decidim::Proposals::Proposal",
               foreign_key: "decidim_proposals_proposal_state_id",
               inverse_of: false,
               dependent: :restrict_with_error
    end
  end
end
