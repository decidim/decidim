# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TwoFactor
    describe SetupHelper do
      let(:authenticator) { create(:totp_authenticator, :confirmed) }

      describe "#totp_qr_code_data_uri" do
        it "renders the provisioning URI as an inline SVG image" do
          expect(helper.totp_qr_code_data_uri(authenticator)).to start_with("data:image/svg+xml;base64,")
        end
      end

      describe "#totp_manual_key" do
        it "groups the secret in blocks of four" do
          expect(helper.totp_manual_key(authenticator)).to eq(authenticator.secret.scan(/.{1,4}/).join(" "))
        end
      end

      describe "#two_factor_usage" do
        it "describes when the factor was added and last used" do
          expect(helper.two_factor_usage(authenticator)).to eq("Added on #{I18n.l(authenticator.confirmed_at.to_date, format: :decidim_short)}")

          authenticator.update!(last_used_at: Time.current)

          expect(helper.two_factor_usage(authenticator)).to end_with("Last used on #{I18n.l(Time.current.to_date, format: :decidim_short)}")
        end
      end
    end
  end
end
