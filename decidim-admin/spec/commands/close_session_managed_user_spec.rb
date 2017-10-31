# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe CloseSessionManagedUser do
    subject { described_class.new(user, current_user) }

    let(:organization) { create :organization }
    let(:current_user) { create :user, :admin, organization: organization }
    let(:user) { create :user, :managed, organization: organization }
    let!(:impersonation_log) { create(:impersonation_log, admin: current_user, user: user) }

    context "when everything is ok" do
      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "ends the impersonation log" do
        subject.call
        expect(impersonation_log.reload).to be_ended
      end
    end

    context "when there is no active session for this admin and user" do
      before do
        impersonation_log.update_attributes!(ended_at: Time.current)
      end

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
