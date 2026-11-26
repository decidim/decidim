# frozen_string_literal: true

class RenameProposalStateChangedEventNotifications < ActiveRecord::Migration[7.0]
  LEGACY_EVENT_CLASS = "Decidim::Proposals::ProposalStateChangedEvent"
  EVENT_CLASS = "Decidim::Proposals::ProposalStatusChangedEvent"
  EVENT_NAMES = {
    "decidim.events.proposals.proposal_state_changed" => "decidim.events.proposals.proposal_status_changed",
    "decidim.events.proposals.proposal_state_changed_for_authors" => "decidim.events.proposals.proposal_status_changed_for_authors"
  }.freeze

  class Notification < ApplicationRecord
    self.table_name = :decidim_notifications
  end

  def up
    # rubocop:disable Rails/SkipsModelValidations
    EVENT_NAMES.each do |legacy_name, event_name|
      Notification.where(event_class: LEGACY_EVENT_CLASS, event_name: legacy_name).update_all(event_name:)
    end

    Notification.where(event_class: LEGACY_EVENT_CLASS).update_all(event_class: EVENT_CLASS)
    # rubocop:enable Rails/SkipsModelValidations
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
