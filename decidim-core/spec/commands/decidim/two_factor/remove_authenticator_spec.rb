# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TwoFactor
    describe RemoveAuthenticator do
      subject { described_class.new(authenticator) }

      let(:user) { create(:user, :confirmed, :with_recovery_codes) }
      let!(:authenticator) { create(:totp_authenticator, :confirmed, user:) }

      context "when it is the last factor" do
        it "removes the factor and the recovery codes left behind" do
          expect { subject.call }.to broadcast(:ok).and(change(TotpAuthenticator, :count).by(-1)).and(change(RecoveryCode, :count).to(0))
        end
      end

      context "when another factor is still attached" do
        before { create(:email_authenticator, user:) }

        it "removes only the given factor and keeps the recovery codes" do
          expect { subject.call }.to change(user.two_factor_authenticators, :count).by(-1)
          expect(RecoveryCode.where(user:)).to be_present
        end
      end

      context "when there is no such factor" do
        let(:authenticator) { nil }

        it "broadcasts invalid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end
    end
  end
end
