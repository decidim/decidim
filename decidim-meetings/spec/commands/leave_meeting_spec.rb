# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::LeaveMeeting do
  let(:registrations_enabled) { true }
  let(:available_slots) { 10 }
  let(:meeting) { create :meeting, registrations_enabled: registrations_enabled, available_slots: available_slots }
  let(:user) { create :user, :confirmed, organization: meeting.organization }
  let(:user_leaving_meeting) { user }
  subject { described_class.new(meeting, user_leaving_meeting) }

  before do
    create(:registration, meeting: meeting, user: user)
  end

  context "when everything is ok" do
    it "broadcasts ok" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "destroys the registration for the meeting and the user" do
      expect { subject.call }.to change { Decidim::Meetings::Registration.count }.by(-1)
    end
  end

  context "when the user has not joined the meeting" do
    let(:user_leaving_meeting) { create :user, :confirmed, organization: meeting.organization }

    it "broadcasts invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end
end
