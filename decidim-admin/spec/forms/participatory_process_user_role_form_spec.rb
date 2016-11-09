# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Admin
    describe ParticipatoryProcessUserRoleForm do
      let(:email) { "my_email@example.org" }
      let(:attributes) do
        {
          "participatory_process_user_role" => {
            "email" => email,
          }
        }
      end

      subject { described_class.from_params(attributes) }

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when email is missing" do
        let(:email) { }

        it { is_expected.to be_invalid }
      end
    end
  end
end
