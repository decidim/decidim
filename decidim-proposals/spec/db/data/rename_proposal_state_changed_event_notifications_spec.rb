# frozen_string_literal: true

require "spec_helper"

require "./db/data/20261105090000_rename_proposal_state_changed_event_notifications"

describe RenameProposalStateChangedEventNotifications do
  let(:migrator) do
    described_class.new.tap do |migration|
      migration.verbose = false
    end
  end

  let!(:notification) do
    create(
      :notification,
      event_name: "decidim.events.proposals.proposal_state_changed",
      event_class: "Decidim::Proposals::ProposalStateChangedEvent"
    )
  end

  let!(:authors_notification) do
    create(
      :notification,
      event_name: "decidim.events.proposals.proposal_state_changed_for_authors",
      event_class: "Decidim::Proposals::ProposalStateChangedEvent"
    )
  end

  let!(:other_notification) { create(:notification) }

  it "renames the stored event classes and names" do
    migrator.migrate(:up)

    expect(notification.reload.event_class).to eq("Decidim::Proposals::ProposalStatusChangedEvent")
    expect(notification.event_name).to eq("decidim.events.proposals.proposal_status_changed")
    expect(authors_notification.reload.event_name).to eq("decidim.events.proposals.proposal_status_changed_for_authors")
    expect(authors_notification.event_class).to eq("Decidim::Proposals::ProposalStatusChangedEvent")
  end

  it "leaves other notifications untouched" do
    expect { migrator.migrate(:up) }.not_to(change { other_notification.reload.attributes })
  end
end
