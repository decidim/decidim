# frozen_string_literal: true

class RenameProposalStatesToProposalStatuses < ActiveRecord::Migration[7.0]
  LEGACY_STATE_INDEXES = { 0 => "not_answered", 10 => "evaluating", 20 => "accepted", -10 => "rejected", -20 => "withdrawn" }.freeze
  STATE_TO_STATUS_CHANGESET_KEYS = {
    "state" => "status",
    "decidim_proposals_proposal_state_id" => "decidim_proposals_proposal_status_id",
    "state_published_at" => "status_published_at"
  }.freeze
  class ActionLog < ApplicationRecord
    self.table_name = :decidim_action_logs
  end

  class Version < ApplicationRecord
    self.table_name = :versions
  end

  def up
    rename_index :decidim_proposals_proposal_states, :index_decidim_proposals_proposal_states_on_decidim_component_id, :index_decidim_proposals_proposal_statuses_on_component_id
    rename_table :decidim_proposals_proposal_states, :decidim_proposals_proposal_statuses
    rename_column :decidim_proposals_proposals, :decidim_proposals_proposal_state_id, :decidim_proposals_proposal_status_id
    rename_column :decidim_proposals_proposals, :state_published_at, :status_published_at

    # rubocop:disable Rails/SkipsModelValidations
    Version.where(item_type: "Decidim::Proposals::ProposalState").update_all(item_type: "Decidim::Proposals::ProposalStatus")
    ActionLog.where(resource_type: "Decidim::Proposals::ProposalState").update_all(resource_type: "Decidim::Proposals::ProposalStatus")
    # rubocop:enable Rails/SkipsModelValidations

    rename_state_changesets
  end

  def down
    # rubocop:disable Rails/SkipsModelValidations
    Version.where(item_type: "Decidim::Proposals::ProposalStatus").update_all(item_type: "Decidim::Proposals::ProposalState")
    ActionLog.where(resource_type: "Decidim::Proposals::ProposalStatus").update_all(resource_type: "Decidim::Proposals::ProposalState")
    # rubocop:enable Rails/SkipsModelValidations

    rename_status_changesets

    rename_column :decidim_proposals_proposals, :status_published_at, :state_published_at
    rename_column :decidim_proposals_proposals, :decidim_proposals_proposal_status_id, :decidim_proposals_proposal_state_id
    rename_index :decidim_proposals_proposal_statuses, :index_decidim_proposals_proposal_statuses_on_component_id, :index_decidim_proposals_proposal_states_on_decidim_component_id
    rename_table :decidim_proposals_proposal_statuses, :decidim_proposals_proposal_states
  end

  private

  def rename_state_changesets
    Version.where(item_type: "Decidim::Proposals::Proposal")
           .where(changeset_keys_sql(STATE_TO_STATUS_CHANGESET_KEYS.keys))
           .find_each do |version|
      changeset = version.object_changes
      STATE_TO_STATUS_CHANGESET_KEYS.each do |legacy_key, status_key|
        next unless changeset.has_key?(legacy_key)

        values = changeset.delete(legacy_key)
        changeset[status_key] = if legacy_key == "state"
                                  values.map { |value| LEGACY_STATE_INDEXES.fetch(value) { value } }
                                else
                                  values
                                end
      end
      version.update_column(:object_changes, changeset) # rubocop:disable Rails/SkipsModelValidations
    end
  end

  def rename_status_changesets
    Version.where(item_type: "Decidim::Proposals::Proposal")
           .where(changeset_keys_sql(STATE_TO_STATUS_CHANGESET_KEYS.values))
           .find_each do |version|
      changeset = version.object_changes
      STATE_TO_STATUS_CHANGESET_KEYS.each do |legacy_key, status_key|
        next unless changeset.has_key?(status_key)

        changeset[legacy_key] = changeset.delete(status_key)
      end
      version.update_column(:object_changes, changeset) # rubocop:disable Rails/SkipsModelValidations
    end
  end

  def changeset_keys_sql(keys)
    keys.map { |key| "object_changes ->> '#{key}' IS NOT NULL" }.join(" OR ")
  end
end
