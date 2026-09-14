# frozen_string_literal: true

require "spec_helper"

describe "Two-factor authentication" do
  include_context "with a two-factor organization"

  before { switch_to_host(organization.host) }

  context "when no factor is attached" do
    before do
      login_as user, scope: :user
      visit decidim.two_factor_authentication_path
    end

    it "lists the available methods" do
      expect(page).to have_link("Two-factor authentication", href: decidim.two_factor_authentication_path)
      expect(page).to have_text("Two-factor methods")
      expect(page).to have_text("Authenticator app")
      expect(page).to have_text("Email code")
      expect(page).to have_no_text("unused codes")
    end

    it "adds the authenticator app and shows the recovery codes once" do
      click_on "Add authenticator app"

      expect(page).to have_text("Scan this QR code with the app")
      expect(page).to have_css("img[src^='data:image/svg+xml;base64,']")

      secret = Decidim::TwoFactor::TotpAuthenticator.find_by(user:).secret
      fill_in "Enter the 6-digit code the app shows", with: totp_code_for(secret)
      click_on "Confirm"

      expect(page).to have_text("Recovery codes")
      expect(page).to have_css("code", count: Decidim.two_factor_recovery_codes_count)

      click_on "I have saved the codes"

      expect(page).to have_text("Added on #{I18n.l(Time.zone.today, format: :decidim_short)}")
      expect(page).to have_text("#{Decidim.two_factor_recovery_codes_count} unused codes")
      expect(user.reload).to be_two_factor_enabled
    end

    it "rejects a wrong code" do
      click_on "Add authenticator app"
      fill_in "Enter the 6-digit code the app shows", with: "000000"
      click_on "Confirm"

      expect(page).to have_text("The code is not correct")
      expect(user.reload).not_to be_two_factor_enabled
    end

    it "enables the email code" do
      click_on "Enable email code"

      expect(page).to have_text("Recovery codes")

      click_on "I have saved the codes"

      expect(page).to have_text("Codes are sent to #{user.email}")
      expect(user.reload).to be_two_factor_enabled
    end
  end

  context "when a factor is already attached" do
    let(:user) { create(:user, :confirmed, :with_recovery_codes, organization:) }
    let!(:authenticator) { create(:totp_authenticator, :confirmed, user:) }

    before do
      login_as user, scope: :user
      visit decidim.two_factor_authentication_path
    end

    it "removes it once the removal is confirmed" do
      accept_confirm { click_on "Remove" }

      expect(page).to have_text("The second factor was removed from your account")
      expect(page).to have_no_text("unused codes")
      expect(user.reload).not_to be_two_factor_enabled
    end

    it "regenerates the recovery codes once the regeneration is confirmed" do
      accept_confirm { click_on "Regenerate" }

      expect(page).to have_text("Recovery codes")
      expect(page).to have_css("code", count: Decidim.two_factor_recovery_codes_count)
      expect(page).to have_css("a[download='decidim-recovery-codes.txt']")

      click_on "I have saved the codes"

      expect(page).to have_text("#{Decidim.two_factor_recovery_codes_count} unused codes")
    end
  end

  context "when the organization has two-factor authentication disabled" do
    let(:organization) { create(:organization) }

    before do
      login_as user, scope: :user
      visit decidim.two_factor_authentication_path
    end

    it "hides the page and its menu entry" do
      expect(page).to have_current_path(decidim.account_path)
      expect(page).to have_no_link("Two-factor authentication")
    end
  end
end
