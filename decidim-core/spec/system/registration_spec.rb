# frozen_string_literal: true

require "spec_helper"

def fill_registration_form(
  name: "Nikola Tesla",
  nickname: "the-greatest-genius-in-history",
  email: "nikola.tesla@example.org",
  password: "sekritpass123"
)
  fill_in :registration_user_name, with: name
  fill_in :registration_user_nickname, with: nickname
  fill_in :registration_user_email, with: email
  fill_in :registration_user_password, with: password
  fill_in :registration_user_password_confirmation, with: password
end

describe "Registration", type: :system do
  let(:organization) { create(:organization) }
  let!(:terms_and_conditions_page) { Decidim::StaticPage.find_by(slug: "terms-and-conditions", organization:) }

  before do
    switch_to_host(organization.host)
    visit decidim.new_user_registration_path
  end

  context "when signing up" do
    describe "on first sight" do
      it "shows fields empty" do
        expect(page).to have_content("Sign up to participate")
        expect(page).to have_field("registration_user_name", with: "")
        expect(page).to have_field("registration_user_nickname", with: "")
        expect(page).to have_field("registration_user_email", with: "")
        expect(page).to have_field("registration_user_password", with: "")
        expect(page).to have_field("registration_user_password_confirmation", with: "")
        expect(page).to have_field("registration_user_newsletter", checked: false)
      end
    end

    describe "on cached sight with a different language", :caching do
      it "shows the omniauth buttons in correct locale" do
        expect(page).to have_link("Sign in with Facebook")

        within_language_menu do
          click_link "Català"
        end

        expect(page).to have_link("Inicia sessió amb Facebook")
      end
    end
  end

  context "when newsletter checkbox is unchecked" do
    it "opens modal on submit" do
      within "form.new_user" do
        find("*[type=submit]").click
      end
      expect(page).to have_css("#sign-up-newsletter-modal", visible: :visible)
      expect(page).to have_current_path decidim.new_user_registration_path
    end

    it "checks when clicking the checking button" do
      within "form.new_user" do
        find("*[type=submit]").click
      end
      click_button "Check and continue"
      expect(page).to have_current_path decidim.new_user_registration_path
      expect(page).to have_css("#sign-up-newsletter-modal", visible: :all)
      expect(page).to have_field("registration_user_newsletter", checked: true)
    end

    it "submit after modal has been opened and selected an option" do
      within "form.new_user" do
        find("*[type=submit]").click
      end
      click_button "Keep unchecked"
      expect(page).to have_css("#sign-up-newsletter-modal", visible: :all)
      fill_registration_form
      within "form.new_user" do
        find("*[type=submit]").click
      end
      expect(page).to have_current_path decidim.user_registration_path
      expect(page).to have_field("registration_user_newsletter", checked: false)
    end
  end

  context "when newsletter checkbox is checked but submit fails" do
    before do
      fill_registration_form
      page.check("registration_user_newsletter")
    end

    it "keeps the user newsletter checkbox true value" do
      within "form.new_user" do
        find("*[type=submit]").click
      end
      expect(page).to have_current_path decidim.user_registration_path
      expect(page).to have_field("registration_user_newsletter", checked: true)
    end
  end

  context "when the user is promoted to an admin after the registration" do
    let(:user) { Decidim::User.last }

    before do
      # Add a content block to the home page to see if the user is there
      create :content_block, organization:, scope_name: :homepage, manifest_name: :hero

      # Register
      fill_registration_form(password:)
      page.check("registration_user_tos_agreement")
      page.check("registration_user_newsletter")
      within "form.new_user" do
        find("*[type=submit]").click
      end
      expect(page).to have_content("A message with a confirmation link has been sent to your email address.")
      user.admin = true
      user.confirmed_at = Time.current
      user.save!

      # Sign in
      click_link "Sign In"
      fill_in :session_user_email, with: user.email
      fill_in :session_user_password, with: password
      click_button "Log in"
    end

    context "with a weak password" do
      let(:password) { "sekritpass123" }

      it "requires a password change" do
        expect(page).to have_content("Password change")
      end
    end

    context "with a strong password" do
      let(:password) { "decidim123456789" }

      it "does not require password change straight away" do
        expect(page).not_to have_content("Password change")
      end
    end
  end
end
