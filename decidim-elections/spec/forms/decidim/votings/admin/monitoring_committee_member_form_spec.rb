# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    module Admin
      describe MonitoringCommitteeMemberForm do
        subject(:form) { described_class.from_params(attributes).with_context(context) }

        let(:organization) { create :organization }
        let(:context) do
          {
            current_organization: organization
          }
        end

        let(:name) { ::Faker::Name.name }
        let(:email) { ::Faker::Internet.email }
        let(:user_id) { nil }
        let(:existing_user) { false }
        let(:attributes) do
          {
            name:,
            email:,
            existing_user:,
            user_id:
          }
        end

        context "when existing user is false" do
          describe "when email and name are present" do
            it { is_expected.to be_valid }
          end

          describe "when email is invalid" do
            let(:email) { "invalid#email.org" }

            it { is_expected.not_to be_valid }
          end

          describe "when name is invalid" do
            let(:name) { "Miao<121" }

            it { is_expected.not_to be_valid }
          end

          describe "when name is missing" do
            let(:name) { nil }

            it { is_expected.not_to be_valid }
          end

          describe "when email is missing" do
            let(:email) { nil }

            it { is_expected.not_to be_valid }
          end
        end

        context "when existing user is true" do
          let(:existing_user) { true }

          describe "when name and email are missing but user_id is present" do
            let(:name) { nil }
            let(:email) { nil }
            let(:user_id) { create(:user, organization:).id }

            it { is_expected.to be_valid }
          end

          describe "when name, email and user_id are missing" do
            let(:name) { nil }
            let(:email) { nil }
            let(:user_id) { nil }

            it { is_expected.not_to be_valid }
          end
        end
      end
    end
  end
end
