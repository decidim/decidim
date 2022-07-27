# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe LeaveConference do
    subject { described_class.new(conference, registration_type, user_leaving_conference) }

    let(:registrations_enabled) { true }
    let(:available_slots) { 10 }
    let!(:conference) { create :conference, registrations_enabled:, available_slots: }
    let!(:registration_type) { create :registration_type, conference: }
    let(:user) { create :user, :confirmed, organization: conference.organization }
    let(:user_leaving_conference) { user }

    before do
      create(:conference_registration, conference:, user:, registration_type:)
    end

    context "when everything is ok" do
      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "destroys the registration for the conference and the user" do
        expect { subject.call }.to change(ConferenceRegistration, :count).by(-1)
      end
    end

    context "when the user has not joined the conference" do
      let(:user_leaving_conference) { create :user, :confirmed, organization: conference.organization }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
