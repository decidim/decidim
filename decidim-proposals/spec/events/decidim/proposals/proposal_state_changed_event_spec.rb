# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::ProposalStateChangedEvent do
  subject(:event) do
    described_class.new(
      resource: nil,
      event_name: "decidim.events.proposals.proposal_state_changed",
      user: nil,
      user_role: :follower
    )
  end

  it "keeps working for notifications and jobs queued before the rename" do
    expect(described_class).to be < Decidim::Proposals::ProposalStatusChangedEvent
    expect(event.i18n_scope).to eq("decidim.events.proposals.proposal_status_changed.follower")
  end
end
