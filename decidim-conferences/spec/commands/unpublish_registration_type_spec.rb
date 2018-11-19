# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe Admin::UnpublishRegistrationType do
    subject { described_class.new(registration_type, user) }

    let(:conference) { create :conference }
    let!(:registration_type) { create :registration_type, :published, conference: conference }
    let(:user) { create :user, organization: conference.organization }

    context "when the registration type is nil" do
      let(:registration_type) { nil }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the registration type is not published" do
      let(:registration_type) { create :registration_type, :unpublished, conference: conference }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the registration type is published" do
      it "is valid" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "unpublishes it" do
        subject.call
        registration_type.reload
        expect(registration_type).not_to be_published
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with(:unpublish, registration_type, user)
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)

        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.version.event).to eq "update"
      end
    end
  end
end
