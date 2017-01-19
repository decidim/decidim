# frozen_string_literal: true
require "spec_helper"

module Decidim
  describe RegistrationForm do
    subject do
      described_class.from_params(
        attributes
      )
    end

    let(:name) { "User" }
    let(:email) { "user@decidim.org" }
    let(:password) { "password1234" }
    let(:password_confirmation) { password }
    let(:tos_agreement) { "1" }

    let(:attributes) do
      {
        name: name,
        email: email,
        password: password,
        password_confirmation: password_confirmation,
        tos_agreement: tos_agreement
      }
    end

    context "when everything is OK" do
      it { is_expected.to be_valid }
    end

    context "when the name is not present" do
      let(:name) { nil }
      it { is_expected.to be_invalid }
    end

    context "when the email is not present" do
      let(:email) { nil }      
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
  end
end