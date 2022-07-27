# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe DeclineInvitation do
    subject { described_class.new(meeting, user) }

    let(:registrations_enabled) { true }
    let(:organization) { create :organization }
    let(:participatory_process) { create :participatory_process, organization: }
    let(:component) { create :component, manifest_name: :meetings, participatory_space: participatory_process }
    let(:meeting) { create :meeting, component:, registrations_enabled: }
    let(:user) { create :user, :confirmed, organization: }
    let!(:invitation) { create(:invite, meeting:, user:) }

    context "when everything is ok" do
      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "declines the invitation" do
        expect { subject.call }.to change { invitation.reload.rejected_at }.from(nil).to(kind_of(Time))
      end
    end

    context "when the meeting has not registrations enabled" do
      let(:registrations_enabled) { false }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the invitation doesn't exists" do
      let(:invitation) { nil }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
