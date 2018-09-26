# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe Admin::PublishConference do
    subject { described_class.new(my_conference, user) }

    let(:my_conference) { create :conference, :unpublished, organization: user.organization }
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
    end
  end
end
