# frozen_string_literal: true

require "spec_helper"

describe "Two-factor authentication" do
  include_context "with a two-factor request session"

  before { sign_in_with_password }

  describe "DELETE destroy" do
    it "leaves the factors of other participants alone" do
      other = create(:totp_authenticator, :confirmed, user: create(:user, :confirmed, organization:))

      delete(routes.two_factor_authentication_authenticator_path(other, locale: "en"), headers:)

      expect(other.reload).to be_persisted
      expect(flash[:alert]).to be_present
    end
  end

  describe "POST recovery_codes" do
    context "when no factor is attached" do
      it "redirects without generating anything" do
        post(routes.two_factor_authentication_recovery_codes_path(locale: "en"), headers:)

        expect(response).to redirect_to(routes.two_factor_authentication_path(locale: "en"))
        expect(Decidim::TwoFactor::RecoveryCode.where(user:)).to be_empty
      end
    end

    it_behaves_like "a two-factor page hidden without two-factor authentication" do
      let(:path) { routes.two_factor_authentication_recovery_codes_path(locale: "en") }
    end
  end

  describe "POST totp_authenticator" do
    context "when no enrollment is pending" do
      it "redirects without confirming anything" do
        post(routes.two_factor_authentication_totp_authenticator_path(locale: "en"), params: { code: "123456" }, headers:)

        expect(response).to redirect_to(routes.two_factor_authentication_path(locale: "en"))
        expect(Decidim::TwoFactor::Authenticator.confirmed.where(user:)).to be_empty
      end
    end
  end

  describe "GET new totp_authenticator" do
    context "when the method is not available" do
      before { allow(Decidim).to receive(:two_factor_methods).and_return([:email]) }

      it "redirects without enrolling anything" do
        get(routes.new_two_factor_authentication_totp_authenticator_path(locale: "en"), headers:)

        expect(response).to redirect_to(routes.two_factor_authentication_path(locale: "en"))
        expect(Decidim::TwoFactor::Authenticator.where(user:)).to be_empty
      end
    end

    it_behaves_like "a two-factor page hidden without two-factor authentication" do
      let(:path) { routes.new_two_factor_authentication_totp_authenticator_path(locale: "en") }
    end
  end

  describe "GET on the pages rendered in response to a POST" do
    before { create(:totp_authenticator, :confirmed, user:) }

    it "lands on the settings page instead of failing" do
      get(routes.two_factor_authentication_recovery_codes_path(locale: "en"), headers:)

      expect(response).to redirect_to(routes.two_factor_authentication_path(locale: "en"))
    end
  end

  describe "GET show" do
    context "when the organization narrows the available methods" do
      before { organization.update!(available_two_factor_methods: %w(totp)) }

      it "offers only the allowed methods" do
        get(routes.two_factor_authentication_path(locale: "en"), headers:)

        expect(response.body).to include("Add authenticator app")
        expect(response.body).not_to include("Enable email code")
      end
    end

    it_behaves_like "a two-factor page hidden without two-factor authentication" do
      let(:path) { routes.two_factor_authentication_path(locale: "en") }
    end
  end
end
