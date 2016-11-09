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
    end
  end
end
