# frozen_string_literal: true

class ChangeStateOnCollaborativeDrafts < ActiveRecord::Migration[6.1]
  def up
    rename_column :decidim_proposals_collaborative_drafts, :state, :old_state
    add_column :decidim_proposals_collaborative_drafts, :state, :integer, default: 0, null: false

    Decidim::Proposals::CollaborativeDraft.reset_column_information

    Decidim::Proposals::CollaborativeDraft.find_each do |collaborative_draft|
      collaborative_draft.update(state: Decidim::Proposals::CollaborativeDraft::STATES.index(collaborative_draft.old_state) || "not_answered")
    end

    remove_column :decidim_proposals_collaborative_drafts, :old_state
    Decidim::Proposals::CollaborativeDraft.reset_column_information
  end

  def down
    rename_column :decidim_proposals_collaborative_drafts, :state, :old_state
    add_column :decidim_proposals_collaborative_drafts, :state, :string

    Decidim::Proposals::CollaborativeDraft.reset_column_information

    Decidim::Proposals::CollaborativeDraft.find_each do |collaborative_draft|
      collaborative_draft.update(state: Decidim::Proposals::CollaborativeDraft::STATES[collaborative_draft.old_state])
    end

    remove_column :decidim_proposals_collaborative_drafts, :old_state
    Decidim::Proposals::CollaborativeDraft.reset_column_information
  end
end
