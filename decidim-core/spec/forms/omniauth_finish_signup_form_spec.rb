# frozen_string_literal: true
require "spec_helper"

module Decidim
  describe OmniauthFinishSignupForm do
    subject do
      described_class.from_params(
        attributes
      )
    end

    let(:attributes) do
      {
        name: "New User",
        password: "12345",
        password_confirmation: "12345",
        provider: "facebook",
        uid: "67890"
      }
    end

    describe "#oauth_signature" do
      it "generates a signature based on the provider and uid" do
        expect(OmniauthFinishSignupForm).to receive(:create_signature).with(subject.provider, subject.uid).and_return("mysignature")
        expect(subject.oauth_signature).to eq("mysignature")
      end
    end

    describe ".verify_signature" do
      it "returns true if the signature is correct" do
        expect(OmniauthFinishSignupForm.verify_signature(subject.provider, subject.uid, subject.oauth_signature)).to be_truthy
      end

      it "returns false if the signature is not correct" do
        expect(OmniauthFinishSignupForm.verify_signature(subject.provider, subject.uid, "abcdefg")).to be_falsy
      end
    end
  end
end