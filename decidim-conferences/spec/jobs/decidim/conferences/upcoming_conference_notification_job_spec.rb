# frozen_string_literal: true

require "spec_helper"

describe Decidim::Conferences::UpcomingConferenceNotificationJob do
  subject { described_class }

  let(:organization) { create :organization }
  let(:user) { create :user, organization: }
  let(:start_date) { 1.day.from_now }
  let(:conference) { create :conference, start_date:, organization: }
  let(:component) { create :component, manifest_name: :conferences, participatory_space: conference }
  let!(:checksum) { subject.generate_checksum(conference) }
  let!(:follow) { create :follow, followable: conference, user: }

  context "when the checksum is correct" do
    it "notifies the upcoming conference" do
      expect(Decidim::EventsManager)
        .to receive(:publish)
        .with(
          event: "decidim.events.conferences.upcoming_conference",
          event_class: Decidim::Conferences::UpcomingConferenceEvent,
          resource: conference,
          followers: [user]
        )

      subject.perform_now(conference.id, checksum)
    end
  end

  context "when the checksum is not correct" do
    let(:checksum) { "1234" }

    it "doesn't notify the upcoming conference" do
      expect(Decidim::EventsManager)
        .not_to receive(:publish)

      subject.perform_now(conference.id, checksum)
    end
  end
end
