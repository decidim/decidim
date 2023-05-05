# frozen_string_literal: true

class ChangeStateOnProposals < ActiveRecord::Migration[6.1]
  class Proposal < ApplicationRecord
    self.table_name = :decidim_proposals_proposals
    STATES = %w(not_answered evaluating accepted rejected withdrawn).freeze
  end

  def up
    rename_column :decidim_proposals_proposals, :state, :old_state
    add_column :decidim_proposals_proposals, :state, :integer, default: 0, null: false

    Proposal.reset_column_information

    Proposal.find_each do |proposal|
      proposal.update(state: Proposal::STATES.index(proposal.old_state).to_i)
    end

    remove_column :decidim_proposals_proposals, :old_state
    Proposal.reset_column_information
  end

  def down
    rename_column :decidim_proposals_proposals, :state, :old_state
    add_column :decidim_proposals_proposals, :state, :string

    Proposal.reset_column_information

    Proposal.find_each do |proposal|
      proposal.update(state: Proposal::STATES[proposal.old_state])
    end

    remove_column :decidim_proposals_proposals, :old_state
    Proposal.reset_column_information
  end
end
