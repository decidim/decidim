# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::JoinMeeting do
  let(:inscriptions_enabled) { true }
  let(:available_slots) { 10 }
  let(:meeting) { create :meeting, inscriptions_enabled: inscriptions_enabled, available_slots: available_slots }
  let(:user) { create :user, :confirmed, organization: meeting.organization }
  subject { described_class.new(meeting, user) }

  context "when everything is ok" do
    it "broadcasts ok" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "creates an inscription for the meeting and the user" do
      expect { subject.call }.to change { Decidim::Meetings::Inscription.count }.by(1)
      last_inscription = Decidim::Meetings::Inscription.last
      expect(last_inscription.user).to eq(user)
      expect(last_inscription.meeting).to eq(meeting)
    end
  end

  context "when the meeting has not inscriptions enabled" do
    let(:inscriptions_enabled) { false }

    it "broadcasts invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the meeting has not enough available slots" do
    let(:available_slots) { 1 }

    before do
      create(:inscription, meeting: meeting)
    end

    it "broadcasts invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end
end
