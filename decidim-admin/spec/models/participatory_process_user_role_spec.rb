# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Admin
    describe ParticipatoryProcessUserRole do
      let(:participatory_process_user_role) { build(:participatory_process_user_role, role: role) }
      let(:role) { "admin" }

      subject { participatory_process_user_role }

      it { is_expected.to be_valid }

      context "when the role is not admin" do
        let(:role) { "fake_role" }

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
          create(:participatory_process_user_role, role: role)
        end

        it { is_expected.not_to be_valid }
      end
    end
  end
end
