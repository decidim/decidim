# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Conferences
    module Admin
      describe ConferenceUserRoleForm do
        subject { described_class.from_params(attributes) }

        let(:email) { "my_email@example.org" }
        let(:name) { "John Wayne" }
        let(:role) { "admin" }
        let(:attributes) do
          {
            "conference_user_role" => {
              "email" => email,
              "name" => name,
              "role" => role
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
end
