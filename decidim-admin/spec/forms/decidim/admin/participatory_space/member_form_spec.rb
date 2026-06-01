# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    module ParticipatorySpace
      describe MemberForm do
        subject { described_class.from_params(attributes).with_context(context) }

        let(:organization) { create(:organization) }
        let(:context) { { current_organization: organization } }
        let(:email) { "my_email@example.org" }
        let(:name) { "John Wayne" }
        let(:existing_user) { false }
        let(:user_id) { nil }
        let(:attributes) do
          {
            "member" => {
              "email" => email,
              "name" => name,
              "existing_user" => existing_user,
              "user_id" => user_id
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

        context "when inviting an existing user" do
          let(:existing_user) { true }
          let(:email) { nil }
          let(:name) { nil }
          let(:user) { create(:user, organization:) }
          let(:user_id) { user.id }

          it { is_expected.to be_valid }

          context "when user_id is missing" do
            let(:user_id) { nil }

            it { is_expected.to be_invalid }
          end
        end
      end
    end
  end
end
