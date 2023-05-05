# frozen_string_literal: true

class ChangeStateOnCollaborativeDrafts < ActiveRecord::Migration[6.1]
  class CollaborativeDraft < ApplicationRecord
    self.table_name = :decidim_proposals_collaborative_drafts
    STATES = %w(open published withdrawn).freeze
  end

  def up
    rename_column :decidim_proposals_collaborative_drafts, :state, :old_state
    add_column :decidim_proposals_collaborative_drafts, :state, :integer, default: 0, null: false

    CollaborativeDraft.reset_column_information

    CollaborativeDraft.find_each do |collaborative_draft|
      collaborative_draft.update(state: CollaborativeDraft::STATES.index(collaborative_draft.old_state) || "not_answered")
    end

    remove_column :decidim_proposals_collaborative_drafts, :old_state
    CollaborativeDraft.reset_column_information
  end

  def down
    rename_column :decidim_proposals_collaborative_drafts, :state, :old_state
    add_column :decidim_proposals_collaborative_drafts, :state, :string

    CollaborativeDraft.reset_column_information

    CollaborativeDraft.find_each do |collaborative_draft|
      collaborative_draft.update(state: CollaborativeDraft::STATES[collaborative_draft.old_state])
    end

    remove_column :decidim_proposals_collaborative_drafts, :old_state
    CollaborativeDraft.reset_column_information
  end
end
