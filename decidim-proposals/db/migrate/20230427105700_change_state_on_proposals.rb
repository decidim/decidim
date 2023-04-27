# frozen_string_literal: true

class ChangeStateOnProposals < ActiveRecord::Migration[6.1]
  def up
    rename_column :decidim_proposals_proposals, :state, :old_state
    add_column :decidim_proposals_proposals, :state, :integer, default: 0, null: false

    Decidim::Proposals::Proposal.reset_column_information

    Decidim::Proposals::Proposal.find_each do |proposal|
      proposal.update(state: Decidim::Proposals::Proposal::POSSIBLE_STATES.index(proposal.old_state))
    end

    remove_column :decidim_proposals_proposals, :old_state
    Decidim::Proposals::Proposal.reset_column_information
  end

  def down
    rename_column :decidim_proposals_proposals, :state, :old_state
    add_column :decidim_proposals_proposals, :state, :string

    Decidim::Proposals::Proposal.reset_column_information

    Decidim::Proposals::Proposal.find_each do |proposal|
      proposal.update(state: Decidim::Proposals::Proposal::POSSIBLE_STATES[proposal.old_state])
    end

    remove_column :decidim_proposals_proposals, :old_state
    Decidim::Proposals::Proposal.reset_column_information
  end
end
