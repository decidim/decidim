# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ConferenceUserRole do
    subject { conference_user_role }

    let(:conference_user_role) { build(:conference_user_role, role: role) }
    let(:role) { "admin" }

    it { is_expected.to be_valid }
    it { is_expected.to be_versioned }

    context "when the role is not admin" do
      let(:role) { "fake_role" }

      it { is_expected.not_to be_valid }
    end

    context "when the process and user belong to different organizations" do
      let(:conference_organization) { create(:organization) }
      let(:user_organization) { create(:organization) }

      let(:conference) do
        build(
          :conference,
          organization: conference_organization
        )
      end

      let(:user) { create(:user, organization: user_organization) }

      let(:conference_user_role) do
        build(
          :conference_user_role,
          user: user,
          conference: conference,
          role: "admin"
        )
      end

      it { is_expected.not_to be_valid }
    end

    context "when a role already exists" do
      let(:conference_user_role) do
        build(
          :conference_user_role,
          role: existing_role.role,
          user: existing_role.user,
          conference: existing_role.conference
        )
      end

      let!(:existing_role) do
        create(:conference_user_role, role: role)
      end

      it { is_expected.not_to be_valid }
    end
  end
end
