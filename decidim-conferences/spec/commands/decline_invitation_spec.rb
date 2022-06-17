# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe DeclineInvitation do
    subject { described_class.new(conference, user) }

    let(:registrations_enabled) { true }
    let(:organization) { create :organization }
    let(:conference) { create :conference, organization:, registrations_enabled: }
    let(:user) { create :user, :confirmed, organization: }
    let!(:conference_invitation) { create(:conference_invite, conference:, user:) }

    context "when everything is ok" do
      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "declines the invitation" do
        expect { subject.call }.to change { conference_invitation.reload.rejected_at }.from(nil).to(kind_of(Time))
      end
    end

    context "when the meeting has not registrations enabled" do
      let(:registrations_enabled) { false }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the invitation doesn't exists" do
      let(:conference_invitation) { nil }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
