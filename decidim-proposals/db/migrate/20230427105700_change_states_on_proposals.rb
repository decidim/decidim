# frozen_string_literal: true

class ChangeStatesOnProposals < ActiveRecord::Migration[6.1]
  class Proposal < ApplicationRecord
    self.table_name = :decidim_proposals_proposals
    STATES = { not_answered: 0, evaluating: 10, accepted: 20, rejected: -10, withdrawn: -20 }.freeze
  end

  def up
    rename_column :decidim_proposals_proposals, :state, :old_state
    add_column :decidim_proposals_proposals, :state, :integer, default: 0, null: false

    Proposal.reset_column_information

    Proposal::STATES.each_pair do |status, index|
      Proposal.where(old_state: status).update_all(state: index) # rubocop:disable Rails/SkipsModelValidations
    end

    remove_column :decidim_proposals_proposals, :old_state
  end

  def down
    rename_column :decidim_proposals_proposals, :state, :old_state
    add_column :decidim_proposals_proposals, :state, :string

    Proposal.reset_column_information

    Proposal::STATES.each_pair do |status, index|
      Proposal.where(old_state: index).update_all(state: status) # rubocop:disable Rails/SkipsModelValidations
    end

    remove_column :decidim_proposals_proposals, :old_state
  end
end
