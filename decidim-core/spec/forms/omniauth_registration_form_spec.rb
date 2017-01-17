# frozen_string_literal: true
require "spec_helper"

module Decidim
  describe OmniauthRegistrationForm do
    subject do
      described_class.from_params(
        attributes
      )
    end

    let(:name) { "Facebook User" }
    let(:email) { "user@from-facebook.com" }
    let(:provider) { "facebook" }
    let(:uid) { "12345" }
    let(:tos_agreement) { true }
    let(:attributes) do
      {
        email: email,
        name: name,
        provider: provider,
        uid: uid,
        tos_agreement: tos_agreement
      }
    end

    context "when everything is OK" do
      it { is_expected.to be_valid }
    end

    context "when name is blank" do
      let(:name) { "" }

      it { is_expected.not_to be_valid }
    end

    context "when email is blank" do
      let(:email) { "" }

      it { is_expected.not_to be_valid }
    end

    context "when provider is blank" do
      let(:provider) { "" }

      it { is_expected.not_to be_valid }
    end

    context "when uid is blank" do
      let(:uid) { "" }

      it { is_expected.not_to be_valid }
    end

    context "when tos_agreement is not accepted" do
      let(:tos_agreement) { false }

      it { is_expected.not_to be_valid }
    end

    describe "#oauth_signature" do
      it "generates a signature based on the provider and uid" do
        expect(OmniauthRegistrationForm).to receive(:create_signature).with(subject.provider, subject.uid).and_return("mysignature")
        expect(subject.oauth_signature).to eq("mysignature")
      end
    end

    describe ".verify_signature" do
      it "returns true if the signature is correct" do
        expect(OmniauthRegistrationForm.verify_signature(subject.provider, subject.uid, subject.oauth_signature)).to be_truthy
      end

      it "returns false if the signature is not correct" do
        expect(OmniauthRegistrationForm.verify_signature(subject.provider, subject.uid, "abcdefg")).to be_falsy
      end
    end
  end
end