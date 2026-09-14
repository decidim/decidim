# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TwoFactor
    describe EnableEmailAuthenticator do
      subject { described_class.new(user) }

      let(:user) { create(:user, :confirmed) }

      it_behaves_like "an enrollment issuing recovery codes"

      context "when everything is ok" do
        it "creates the factor ready to use" do
          expect { subject.call }.to change(EmailAuthenticator, :count).by(1)
          expect(user.two_factor_authenticators.confirmed.count).to eq(1)
        end
      end

      context "when the factor is already enabled" do
        before { create(:email_authenticator, user:) }

        it "broadcasts invalid without a second factor" do
          expect { subject.call }.to broadcast(:invalid)
          expect(EmailAuthenticator.where(user:).count).to eq(1)
        end
      end
    end
  end
end
