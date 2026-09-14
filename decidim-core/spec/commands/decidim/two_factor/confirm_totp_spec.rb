# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TwoFactor
    describe ConfirmTotp do
      subject { described_class.new(authenticator, form) }

      let(:user) { create(:user, :confirmed) }
      let(:secret) { ROTP::Base32.random }
      let(:authenticator) { create(:totp_authenticator, user:, secret:) }
      let(:code) { totp_code_for(secret) }
      let(:form) { OtpCodeForm.from_params(code:) }

      it_behaves_like "an enrollment issuing recovery codes"

      context "when everything is ok" do
        it "confirms the authenticator" do
          expect { subject.call }.to change { authenticator.reload.confirmed? }.from(false).to(true)
        end
      end

      context "when the code is wrong" do
        let(:code) { "000000" }

        it "broadcasts invalid and leaves the authenticator unconfirmed" do
          expect { subject.call }.to broadcast(:invalid)
          expect(authenticator.reload).not_to be_confirmed
        end
      end

      context "when the code is blank" do
        let(:code) { "" }

        it "broadcasts invalid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end

      context "when the authenticator is already confirmed" do
        let(:authenticator) { create(:totp_authenticator, :confirmed, user:, secret:) }

        it "broadcasts invalid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end

      context "when there is no pending authenticator" do
        let(:authenticator) { nil }

        it "broadcasts invalid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end
    end
  end
end
