# frozen_string_literal: true

require "spec_helper"

describe Decidim::Admin::ImpersonateManagedUser do
  let(:organization) { create :organization }
  let(:current_user) { create :user, :admin, organization: organization}
  let(:user) { create :user, :managed, organization: organization }

  subject { described_class.new(current_user, user) }

  context "when everything is ok" do
    it "broadcasts ok" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "creates a impersonation log" do
      expect {
        subject.call
      }.to change { ImpersonationLog.count }.by(1)
    end
  end

  context "when the user is not managed" do
    let(:user) { create :user }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end
end
