# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TwoFactor
    describe MethodManifest do
      subject { described_class.new(name:, authenticator_class_name:) }

      let(:name) { "fake" }
      let(:authenticator_class_name) { "Decidim::TwoFactor::TotpAuthenticator" }

      it { is_expected.to be_valid }

      context "when no name is set" do
        let(:name) { nil }

        it { is_expected.to be_invalid }
      end

      context "when no authenticator class is set" do
        let(:authenticator_class_name) { nil }

        it { is_expected.to be_invalid }
      end

      describe "#setup_partial" do
        it "is looked up by the method name unless the manifest names it" do
          expect(subject.setup_partial).to eq("decidim/two_factor/setup/fake")

          subject.setup_partial = "decidim/fake/setup"

          expect(subject.setup_partial).to eq("decidim/fake/setup")
        end
      end

      describe "#challenge_partial" do
        it "is looked up by the method name unless the manifest names it" do
          expect(subject.challenge_partial).to eq("decidim/two_factor/challenge/fake")
        end
      end

      describe "#form_class" do
        it "defaults to the one-time code form" do
          expect(subject.form_class).to eq(OtpCodeForm)
        end
      end
    end
  end
end
