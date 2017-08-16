# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::LeaveMeeting do
  let(:inscriptions_enabled) { true }
  let(:available_slots) { 10 }
  let(:meeting) { create :meeting, inscriptions_enabled: inscriptions_enabled, available_slots: available_slots }
  let(:user) { create :user, :confirmed, organization: meeting.organization }
  subject { described_class.new(meeting, user) }

  before do
    create(:inscription, meeting: meeting, user: user)
  end

  context "when everything is ok" do
    it "broadcasts ok" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "destroys the inscription for the meeting and the user" do
      expect { subject.call }.to change { Decidim::Meetings::Inscription.count }.by(-1)
    end
  end
end
