# frozen_string_literal: true

# The ProposalState model was renamed to ProposalStatus but the
# CreateDefaultProposalStates migration (20240110203504) still references it.
# This migration is ordered before it so the legacy class and the method it
# calls are defined when that migration runs.
class DefineLegacyProposalState < ActiveRecord::Migration[6.1]
  def change; end
end

module Decidim
  module Proposals
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

    def self.create_default_states!(component, admin_user, with_traceability: true)
      create_default_statuses!(component, admin_user, with_traceability:, model: ProposalState)
    end
  end
end
