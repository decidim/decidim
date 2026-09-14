# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TwoFactor
    describe TotpAuthenticator do
      let(:user) { create(:user, :confirmed) }
      let(:secret) { ROTP::Base32.random }
      let(:authenticator) { create(:totp_authenticator, user:, secret:) }

      it "allows a single TOTP authenticator per user" do
        authenticator
        duplicate = build(:totp_authenticator, user:)
        expect(duplicate).not_to be_valid
      end

      describe "secret" do
        it "is stored encrypted" do
          expect(authenticator.read_attribute(:secret)).not_to eq(secret)
        end
      end

      describe ".issue_for" do
        it "starts the enrollment with an unconfirmed authenticator holding a secret" do
          issued = described_class.issue_for(user)

          expect(issued).to have_attributes(secret: be_present, confirmed_at: nil)
          expect(described_class.where(user:).count).to eq(1)
        end

        it "issues a fresh secret on the same authenticator when started again" do
          first_secret = described_class.issue_for(user).secret

          expect { described_class.issue_for(user) }.not_to change(described_class, :count)
          expect(described_class.find_by(user:).secret).not_to eq(first_secret)
        end

        it "issues nothing once the app is confirmed" do
          create(:totp_authenticator, :confirmed, user:)

          expect(described_class.issue_for(user)).to be_nil
        end
      end

      describe "#verify" do
        let(:current_code) { totp_code_for(secret) }
        let(:code) { current_code }
        let(:form) { OtpCodeForm.from_params(code:) }

        it "accepts the current code and stores the consumed timestep" do
          expect(authenticator.verify(form)).to be(true)
          expect(authenticator.reload.last_used_timestep).to be_present
        end

        it "rejects a reused code" do
          authenticator.verify(form)
          expect(authenticator.verify(form)).to be(false)
        end

        it "rejects the code another request used meanwhile" do
          described_class.find(authenticator.id).verify(form)
          expect(authenticator.verify(form)).to be(false)
        end

        it "rejects a wrong or blank code" do
          expect(authenticator.verify(OtpCodeForm.from_params(code: "000000"))).to be(false)
          expect(authenticator.verify(OtpCodeForm.from_params(code: ""))).to be(false)
        end
      end

      describe "#provisioning_uri" do
        it "is an otpauth URI with the user email" do
          expect(authenticator.provisioning_uri).to start_with("otpauth://totp/")
          expect(authenticator.provisioning_uri).to include(CGI.escape(user.email))
        end
      end
    end
  end
end
