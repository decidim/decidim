# frozen_string_literal: true

require "spec_helper"

describe Decidim::Admin::CloseSessionManagedUser do
  let(:organization) { create :organization }
  let(:current_user) { create :user, :admin, organization: organization }
  let(:user) { create :user, :managed, organization: organization }
  let!(:impersonation_log) { create(:impersonation_log, admin: current_user, user: user) }

  subject { described_class.new(user, current_user) }

  context "when everything is ok" do
    it "broadcasts ok" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "ends the impersonation log" do
      subject.call
      expect(impersonation_log.reload.end_at).not_to be_nil
    end
  end

  context "when there is no active session for this admin and user" do
    before do
      impersonation_log.update_attributes(end_at: Time.current)
    end

    it "broadcasts invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end
end
