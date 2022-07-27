# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe InviteUserForm do
    subject do
      described_class.from_params(
        attributes
      ).with_context(
        current_user:,
        current_organization:
      )
    end

    let(:current_organization) { create(:organization) }
    let(:current_user) { create(:user, organization: current_organization) }
    let(:form_organization) { current_organization }
    let(:form_user) { current_user }

    let(:attributes) do
      {
        email: "NewAdmin@example.org",
        name: "New Admin",
        invitation_instructions: "invite_admin",
        role: "admin",
        organization: form_organization,
        invited_by: form_user
      }
    end

    context "when everything is OK" do
      it { is_expected.to be_valid }
    end

    it "downcases the email" do
      expect(subject.email).to eq("newadmin@example.org")
    end

    context "when an admin exists for the given email" do
      before do
        create(:user, :admin, email: "newadmin@example.org", organization: current_organization)
      end

      it { is_expected.to be_invalid }
    end

    context "when no organization given" do
      let(:form_organization) { nil }

      it "defaults to the current organization" do
        expect(subject.organization).to eq(current_organization)
      end
    end

    context "when no current_user given" do
      let(:form_user) { nil }

      it "defaults to the current user" do
        expect(subject.invited_by).to eq(current_user)
      end
    end

    context "when user name contains invalid characters" do
      let(:attributes) do
        {
          email: "NewAdmin@example.org",
          name: "New Admin ()",
          invitation_instructions: "invite_admin",
          role: "admin",
          organization: form_organization,
          invited_by: form_user
        }
      end

      it { is_expected.to be_invalid }
    end
  end
end
