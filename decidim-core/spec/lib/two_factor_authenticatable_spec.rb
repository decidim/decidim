# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe TwoFactorAuthenticatable do
    let(:user) { create(:user, :confirmed) }

    describe "#two_factor_enabled?" do
      it "is not enabled while the factor is unconfirmed" do
        create(:totp_authenticator, user:)

        expect(user.two_factor_enabled?).to be(false)
      end

      it "is enabled once the factor is confirmed" do
        create(:totp_authenticator, :confirmed, user:)

        expect(user.two_factor_enabled?).to be(true)
      end
    end
  end
end
