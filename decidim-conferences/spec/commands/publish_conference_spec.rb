# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe Admin::PublishConference do
    subject { described_class.new(my_conference, user) }

    let!(:my_conference) { create :conference, :unpublished, organization: user.organization, registrations_enabled: true }
    let(:user) { create :user }

    context "when the conference is nil" do
      let(:my_conference) { nil }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the conference is published" do
      let(:my_conference) { create :conference }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the conference is not published" do
      let(:follow) { create :follow, followable: my_conference, user: }

      it "is valid" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "publishes it" do
        subject.call
        my_conference.reload
        expect(my_conference).to be_published
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with("publish", my_conference, user)
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)

        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.version.event).to eq "update"
      end

      it "notifies the change" do
        expect(Decidim::EventsManager)
          .to receive(:publish)
          .with(
            event: "decidim.events.conferences.registrations_enabled",
            event_class: ConferenceRegistrationsEnabledEvent,
            resource: kind_of(Decidim::Conference),
            followers: [follow.user]
          )

        subject.call
      end
    end
  end
end
