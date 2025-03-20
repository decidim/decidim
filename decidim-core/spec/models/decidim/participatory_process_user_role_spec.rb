# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ParticipatoryProcessUserRole do
    subject { participatory_process_user_role }

    let(:participatory_process_user_role) { build(:participatory_process_user_role, role:) }
    let(:role) { "admin" }

    it { is_expected.to be_valid }
    it { is_expected.to be_versioned }

    it "overwrites the log presenter" do
      expect(described_class.log_presenter_class_for(:foo))
        .to eq Decidim::ParticipatoryProcesses::AdminLog::ParticipatoryProcessUserRolePresenter
    end

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
      let(:participatory_process_organization) { create(:organization) }
      let(:user_organization) { create(:organization) }

      let(:participatory_process) do
        build(
          :participatory_process,
          organization: participatory_process_organization
        )
      end

      let(:user) { create(:user, organization: user_organization) }

      let(:participatory_process_user_role) do
        build(
          :participatory_process_user_role,
          user:,
          participatory_process:,
          role: "admin"
        )
      end

      it { is_expected.not_to be_valid }
    end

    context "when a role already exists" do
      let(:participatory_process_user_role) do
        build(
          :participatory_process_user_role,
          role: existing_role.role,
          user: existing_role.user,
          participatory_process: existing_role.participatory_process
        )
      end

      let!(:existing_role) do
        create(:participatory_process_user_role, role:)
      end

      it { is_expected.not_to be_valid }
    end
  end
end
