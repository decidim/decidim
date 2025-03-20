# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AssemblyUserRole do
    subject { assembly_user_role }

    let(:assembly_user_role) { build(:assembly_user_role, role:) }
    let(:role) { "admin" }

    it { is_expected.to be_valid }
    it { is_expected.to be_versioned }

    context "when the role is admin" do
      let(:role) { "admin" }

      it { is_expected.to be_valid }
    end

    context "when the role is collaborator" do
      let(:role) { "collaborator" }

      it { is_expected.to be_valid }
    end

    context "when the role is moderator" do
      let(:role) { "moderator" }

      it { is_expected.to be_valid }
    end

    context "when the role is valuator" do
      let(:role) { "valuator" }

      it { is_expected.to be_valid }
    end

    context "when the role does not exist" do
      let(:role) { "fake_role" }

      it { is_expected.not_to be_valid }
    end

    context "when the process and user belong to different organizations" do
      let(:assembly_organization) { create(:organization) }
      let(:user_organization) { create(:organization) }

      let(:assembly) do
        build(
          :assembly,
          organization: assembly_organization
        )
      end

      let(:user) { create(:user, organization: user_organization) }

      let(:assembly_user_role) do
        build(
          :assembly_user_role,
          user:,
          assembly:,
          role: "admin"
        )
      end

      it { is_expected.not_to be_valid }
    end

    context "when a role already exists" do
      let(:assembly_user_role) do
        build(
          :assembly_user_role,
          role: existing_role.role,
          user: existing_role.user,
          assembly: existing_role.assembly
        )
      end

      let!(:existing_role) do
        create(:assembly_user_role, role:)
      end

      it { is_expected.not_to be_valid }
    end
  end
end
