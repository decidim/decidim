# frozen_string_literal: true

require "spec_helper"

def fill_registration_form
  fill_in :user_name, with: "Nikola Tesla"
  fill_in :user_nickname, with: "the-greatest-genius-in-history"
  fill_in :user_email, with: "nikola.tesla@example.org"
  fill_in :user_password, with: "sekritpass123"
  fill_in :user_password_confirmation, with: "sekritpass123"
end

describe "Registration", type: :system do
  let(:organization) { create(:organization) }
  let!(:terms_and_conditions_page) { create(:static_page, slug: "terms-and-conditions", organization: organization) }

  before do
    switch_to_host(organization.host)
    visit decidim.new_user_registration_path
  end

  context "when signing up" do
    describe "on first sight" do
      it "shows fields empty" do
        expect(page).to have_content("Sign up to participate")
        expect(page).to have_field("user_name", with: "")
        expect(page).to have_field("user_nickname", with: "")
        expect(page).to have_field("user_email", with: "")
        expect(page).to have_field("user_password", with: "")
        expect(page).to have_field("user_password_confirmation", with: "")
        expect(page).to have_field("user_newsletter", checked: false)
      end
    end
  end

  context "when newsletter checkbox is unchecked" do
    it "opens modal on submit" do
      within "form.new_user" do
        find("*[type=submit]").click
      end
      expect(page).to have_css("#sign-up-newsletter-modal", visible: true)
      expect(page).to have_current_path decidim.new_user_registration_path
    end

    it "checks when clicking the checking button" do
      within "form.new_user" do
        find("*[type=submit]").click
      end
      click_button "Check and continue"
      expect(page).to have_current_path decidim.new_user_registration_path
      expect(page).to have_css("#sign-up-newsletter-modal", visible: false)
      expect(page).to have_field("user_newsletter", checked: true)
    end

    it "submit after modal has been opened and selected an option" do
      within "form.new_user" do
        find("*[type=submit]").click
      end
      click_button "Keep uncheck"
      expect(page).to have_css("#sign-up-newsletter-modal", visible: false)
      fill_registration_form
      within "form.new_user" do
        find("*[type=submit]").click
      end
      expect(page).to have_current_path decidim.user_registration_path
      expect(page).to have_field("user_newsletter", checked: false)
    end
  end

  context "when newsletter checkbox is checked but submit fails" do
    before do
      fill_registration_form
      page.check("user_newsletter")
    end

    it "keeps the user newsletter checkbox true value" do
      within "form.new_user" do
        find("*[type=submit]").click
      end
      expect(page).to have_current_path decidim.user_registration_path
      expect(page).to have_field("user_newsletter", checked: true)
    end
  end
end
