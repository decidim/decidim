# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    module ParticipatorySpace
      describe MemberForm do
        subject(:form) { described_class.from_params(attributes).with_context(context) }

        let(:organization) { create(:organization) }
        let(:context) do
          {
            current_organization: organization
          }
        end

        let(:email) { "my_email@example.org" }
        let(:name) { "John Wayne" }
        let(:member_type) { "email" }
        let(:user_id) { nil }
        let(:attributes) do
          {
            "member" => {
              "email" => email,
              "name" => name,
              "member_type" => member_type,
              "user_id" => user_id
            }
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when member_type is email" do
          let(:member_type) { "email" }

          context "when email is missing" do
            let(:email) { nil }

            it { is_expected.to be_invalid }
          end

          context "when email is invalid" do
            let(:email) { "not-an-email" }

            it { is_expected.to be_invalid }
          end

          context "when email is disposable" do
            let(:email) { "test@mailinator.com" }

            it { is_expected.to be_invalid }
          end
        end

        context "when member_type is name" do
          let(:member_type) { "name" }

          context "and no user is provided" do
            it { is_expected.to be_invalid }
          end

          context "and user exists" do
            let(:user_id) { create(:user, organization:).id }

            it { is_expected.to be_valid }
          end

          context "and no such user exists" do
            let(:user_id) { 999_999 }

            it { is_expected.to be_invalid }
          end

          describe "user" do
            subject { form.user }

            context "when the user exists" do
              let(:user_id) { create(:user, organization:).id }

              it { is_expected.to be_a(Decidim::User) }
            end

            context "when the user does not exist" do
              let(:user_id) { 999_999 }

              it { is_expected.to be_nil }
            end

            context "when the user is from another organization" do
              let(:user_id) { create(:user).id }

              it { is_expected.to be_nil }
            end
          end
        end

        context "when member_type is missing" do
          let(:member_type) { nil }

          it { is_expected.to be_invalid }
        end

        context "when member_type is invalid" do
          let(:member_type) { "invalid" }

          it { is_expected.to be_invalid }
        end
      end
    end
  end
end
