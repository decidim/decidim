# frozen_string_literal: true

class ChangeStatesOnCollaborativeDrafts < ActiveRecord::Migration[6.1]
  class CollaborativeDraft < ApplicationRecord
    self.table_name = :decidim_proposals_collaborative_drafts
    STATES = { open: 0, published: 10, withdrawn: -1 }.freeze
  end

  def up
    rename_column :decidim_proposals_collaborative_drafts, :state, :old_state
    add_column :decidim_proposals_collaborative_drafts, :state, :integer, default: 0, null: false

    CollaborativeDraft.reset_column_information

    CollaborativeDraft::STATES.each_pair do |status, index|
      CollaborativeDraft.where(old_state: status).update_all(state: index) # rubocop:disable Rails/SkipsModelValidations
    end

    remove_column :decidim_proposals_collaborative_drafts, :old_state
  end

  def down
    rename_column :decidim_proposals_collaborative_drafts, :state, :old_state
    add_column :decidim_proposals_collaborative_drafts, :state, :string

    CollaborativeDraft.reset_column_information

    CollaborativeDraft::STATES.each_pair do |status, index|
      CollaborativeDraft.where(old_state: index).update_all(state: status) # rubocop:disable Rails/SkipsModelValidations
    end

    remove_column :decidim_proposals_collaborative_drafts, :old_state
  end
end
