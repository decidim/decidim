# frozen_string_literal: true

require "spec_helper"

module Decidim
  module System
    describe AdminForm do
      subject { described_class.from_params(attributes) }

      let(:email) { "admin@example.org" }
      let(:password) { "decidim123456789" }
      let(:password_confirmation) { "decidim123456789" }

      let(:attributes) do
        {
          "admin" => {
            "email" => email,
            "password" => password,
            "password_confirmation" => password_confirmation
          }
        }
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when the email is missing" do
        let(:email) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when the password is missing on create" do
        let(:password) { nil }
        let(:password_confirmation) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when the password confirmation is missing on create" do
        let(:password_confirmation) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when the password is too common" do
        let(:password) { "password1234" }
        let(:password_confirmation) { "password1234" }

        it { is_expected.not_to be_valid }
      end

      context "when the password and confirmation do not match" do
        let(:password_confirmation) { "mismatched123456" }

        it { is_expected.not_to be_valid }
      end

      context "when the email is already taken" do
        let!(:existing_admin) { create(:admin, email:) }

        it { is_expected.not_to be_valid }
      end

      context "when updating an existing admin" do
        let(:admin) { create(:admin) }

        let(:attributes) do
          {
            "admin" => {
              "id" => admin.id,
              "email" => email,
              "password" => password,
              "password_confirmation" => password_confirmation
            }
          }
        end

        context "and everything is OK" do
          it { is_expected.to be_valid }
        end

        context "and the password fields are blank" do
          let(:password) { "" }
          let(:password_confirmation) { "" }

          it { is_expected.to be_valid }
        end

        context "and only the password confirmation is blank" do
          let(:password_confirmation) { "" }

          it { is_expected.not_to be_valid }
        end

        context "and the password and confirmation do not match" do
          let(:password_confirmation) { "mismatched123456" }

          it { is_expected.not_to be_valid }
        end

        context "and the password is too common" do
          let(:password) { "password1234" }
          let(:password_confirmation) { "password1234" }

          it { is_expected.not_to be_valid }
        end

        context "and the email is already taken by another admin" do
          let!(:another_admin) { create(:admin) }
          let(:email) { another_admin.email }

          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end
