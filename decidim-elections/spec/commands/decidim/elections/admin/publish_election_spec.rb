# frozen_string_literal: true

require "spec_helper"

module Decidim::Elections::Admin
  describe PublishElection do
    subject { described_class.new(election, user) }

    let!(:user) { create(:user, :admin, :confirmed, organization: participatory_process.organization) }
    let!(:participatory_process) { election.component.participatory_space }
    let(:step) { participatory_process.steps.first }
    let!(:election) { create(:election) }

    it "publishes the election" do
      expect { subject.call }.to change(election, :published?).from(false).to(true)
    end

    it "traces the action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:perform_action!)
        .with(:publish, election, user, visibility: "all")
        .and_call_original

      expect { subject.call }.to change(Decidim::ActionLog, :count)
      action_log = Decidim::ActionLog.last
      expect(action_log.version).to be_present
    end

    it "fires an event" do
      create :follow, followable: participatory_process, user: user

      expect(Decidim::EventsManager)
        .to receive(:publish)
        .with(
          event: "decidim.events.elections.election_published",
          event_class: Decidim::Elections::ElectionPublishedEvent,
          resource: election,
          followers: [user]
        )

      subject.call
    end
  end
end
