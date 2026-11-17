# frozen_string_literal: true

class CreateDefaultProposalStates < ActiveRecord::Migration[6.1]
  class CustomProposal < ApplicationRecord
    belongs_to :proposal_state,
               class_name: "Decidim::Proposals::ProposalState",
               foreign_key: "decidim_proposals_proposal_state_id",
               inverse_of: :proposals,
               optional: true

    self.table_name = :decidim_proposals_proposals
    STATES = { not_answered: 0, evaluating: 10, accepted: 20, rejected: -10 }.freeze
    enum :old_state, STATES, default: "not_answered"
  end

  def up
    CustomProposal.reset_column_information
    Decidim::Proposals::ProposalState.reset_column_information
    Decidim::Component.unscoped.where(manifest_name: "proposals").find_each do |component|
      admin_user = component.organization.admins.first
      default_states = Decidim::Proposals.create_default_states!(component, admin_user)

      CustomProposal.where(decidim_component_id: component.id).find_each do |proposal|
        next if proposal.old_state == "not_answered"

        token = default_states[proposal.old_state.to_sym][:object]&.token
        proposal.update!(proposal_state: Decidim::Proposals::ProposalState.where(component:, token:).first!)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

# The ProposalState model and its helper were later renamed to ProposalStatus.
# They are kept here because this migration references them, so databases
# rebuilt from migrations keep working after the rename.
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
