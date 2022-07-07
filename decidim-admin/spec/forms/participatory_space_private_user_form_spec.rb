# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe ParticipatorySpacePrivateUserForm do
      subject { described_class.from_params(attributes) }

      let(:email) { "my_email@example.org" }
      let(:name) { "John Wayne" }
      let(:attributes) do
        {
          "participatory_space_private_user" => {
            "email" => email,
            "name" => name
          }
        }
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when email is missing" do
        let(:email) { nil }

        it { is_expected.to be_invalid }
      end
    end
  end
end
