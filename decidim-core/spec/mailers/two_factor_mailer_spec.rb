# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe TwoFactorMailer do
    let(:user) { create(:user, :confirmed) }

    describe "factors_reset" do
      let(:mail) { described_class.factors_reset(user) }

      it "alerts the account email" do
        expect(mail.to).to eq([user.email])
        expect(mail.subject).to eq("Two-factor authentication was reset on your account")
        expect(email_body(mail)).to include("removed all the second factors")
        expect(email_body(mail)).to include("Set up a new second factor")
      end
    end
  end
end
