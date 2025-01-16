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
    enum old_state: STATES, _default: "not_answered"
  end

  def up
    CustomProposal.reset_column_information
    Decidim::Proposals::ProposalState.reset_column_information
    Decidim::Component.unscoped.where(manifest_name: "proposals").find_each do |component|
      admin_user = component.organization.admins.first
      Decidim::Proposals.create_default_states!(component, admin_user)

      CustomProposal.where(decidim_component_id: component.id).find_each do |proposal|
        next if proposal.old_state == "not_answered"

        proposal.update!(proposal_state: Decidim::Proposals::ProposalState.where(component:, token: proposal.old_state).first!)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
