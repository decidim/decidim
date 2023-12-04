# frozen_string_literal: true

class CreateDefaultProposalStates < ActiveRecord::Migration[6.1]
  class Proposal < ApplicationRecord
    belongs_to :proposal_state,
               class_name: "Decidim::Proposals::ProposalState",
               foreign_key: "decidim_proposals_proposal_state_id",
               inverse_of: :proposals,
               optional: true

    self.table_name = :decidim_proposals_proposals
    STATES = { not_answered: 0, evaluating: 10, accepted: 20, rejected: -10, withdrawn: -20 }.freeze
    enum old_state: STATES, _default: "not_answered"
  end

  def up
    Decidim::Component.where(manifest_name: "proposals").find_each do |component|
      admin_user = component.organization.admins.first

      default_states = Decidim::Proposals.create_default_states!(component, admin_user)

      Proposal.where(decidim_component_id: component.id).find_each do |proposal|
        proposal.update!(proposal_state: default_states.dig(proposal.old_state.to_sym, :object))
      end
    end
    change_column_null :decidim_proposals_proposals, :decidim_proposals_proposal_state_id, false

  end

  def down; end
end
