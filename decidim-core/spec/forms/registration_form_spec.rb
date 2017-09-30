# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe RegistrationForm do
    subject do
      described_class.from_params(
        attributes
      ).with_context(
        context
      )
    end

    let(:organization) { create(:organization) }
    let(:sign_up_as) { "user" }
    let(:name) { "User" }
    let(:email) { "user@example.org" }
    let(:password) { "password1234" }
    let(:password_confirmation) { password }
    let(:tos_agreement) { "1" }

    let(:user_group_name) { nil }
    let(:user_group_document_number) { nil }
    let(:user_group_phone) { nil }

    let(:attributes) do
      {
        sign_up_as: sign_up_as,
        name: name,
        email: email,
        password: password,
        password_confirmation: password_confirmation,
        tos_agreement: tos_agreement,
        user_group_name: user_group_name,
        user_group_document_number: user_group_document_number,
        user_group_phone: user_group_phone
      }
    end

    let(:context) do
      {
        current_organization: organization
      }
    end

    context "when everything is OK" do
      it { is_expected.to be_valid }
    end

    context "when the sign_up_as is different from 'user' and 'user_group'" do
      let(:sign_up_as) { "community" }

      it { is_expected.to be_invalid }
    end

    context "when the name is not present" do
      let(:name) { nil }

      it { is_expected.to be_invalid }
    end

    context "when the email is not present" do
      let(:email) { nil }

      it { is_expected.to be_invalid }
    end

    context "when the email already exists" do
      let!(:user) { create(:user, organization: organization, email: email) }

      it { is_expected.to be_invalid }
    end

    context "when the password is not present" do
      let(:password) { nil }

      it { is_expected.to be_invalid }
    end

    context "when the password confirmation is different from password" do
      let(:password_confirmation) { "invalid" }

      it { is_expected.to be_invalid }
    end

    context "when the tos_agreement is not accepted" do
      let(:tos_agreement) { "0" }

      it { is_expected.to be_invalid }
    end

    describe "when sign_up_as is 'user_group'" do
      let(:sign_up_as) { "user_group" }

      let(:user_group_name) { "My organization" }
      let(:user_group_document_number) { "123456789Z" }
      let(:user_group_phone) { "333-333-333" }

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when user_group_name is not present" do
        let(:user_group_name) { nil }

        it { is_expected.to be_invalid }
      end

      context "when user_group_document_number is not present" do
        let(:user_group_document_number) { nil }

        it { is_expected.to be_invalid }
      end

      context "when user_group_phone is not present" do
        let(:user_group_phone) { nil }

        it { is_expected.to be_invalid }
      end

      context "when user_group_name is already taken" do
        let!(:user_group) { create(:user_group, name: user_group_name, decidim_organization_id: organization.id) }
        let(:user_group_name) { "Taken User Name" }

        it { is_expected.to be_invalid }
      end

      context "when user_group_document_number is already taken" do
        let!(:user_group) { create(:user_group, document_number: user_group_document_number, decidim_organization_id: organization.id) }
        let(:user_group_document_number) { "Y12345678" }

        it { is_expected.to be_invalid }
      end
    end
  end
end
