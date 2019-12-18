# frozen_string_literal: true

require "spec_helper"

def fill_registration_form(params = {})
  if params[:step] == 1
    fill_in :user_email, with: "nikola.tesla@example.org"
    fill_in :user_password, with: "sekritpass123"
    fill_in :user_password_confirmation, with: "sekritpass123"
    check("user_tos_agreement")
  end

  if params[:step] == 2
    fill_in :user_name, with: "Nikola Tesla"
    fill_in :user_nickname, with: "the-greatest-genius-in-history"
  end
end

def submit_form
  within("form.new_user") do
    find("*[type=submit]").click
  end
end

describe "Registration", type: :system do
  let(:organization) { create(:organization) }
  let!(:terms_and_conditions_page) { Decidim::StaticPage.find_by(slug: "terms-and-conditions", organization: organization) }

  before do
    switch_to_host(organization.host)
    visit decidim.new_user_registration_path
  end

  context "when signing up" do
    describe "on first sight" do
      it "shows fields empty" do
        expect(page).to have_content("Sign up to participate")
        expect(page).to have_field("user_email", with: "")
        expect(page).to have_field("user_password", with: "")
        expect(page).to have_field("user_password_confirmation", with: "")
      end
    end

    describe "after clicking in next step" do
      it "forces user to fill first step attributes" do
        click_button "Continue"

        expect(page).to have_field("user_email", with: "")
        expect(page).to have_field("user_password", with: "")
        expect(page).to have_field("user_password_confirmation", with: "")
        expect(page).not_to have_field("user_name", with: "")
        expect(page).not_to have_field("user_nickname", with: "")
        expect(page).not_to have_field("user_newsletter", checked: false)
      end

      it "shows fields empty" do
        fill_registration_form(step: 1)
        click_button "Continue"

        expect(page).not_to have_field("user_email")
        expect(page).not_to have_field("user_password")
        expect(page).not_to have_field("user_password_confirmation")
        expect(page).to have_field("user_name", with: "")
        expect(page).to have_field("user_nickname", with: "")
        expect(page).to have_field("user_newsletter", checked: false)
      end
    end
  end

  context "when newsletter checkbox is unchecked" do
    it "opens modal on submit" do
      fill_registration_form(step: 1)
      click_button "Continue"
      fill_registration_form(step: 2)
      submit_form

      expect(page).to have_css("#sign-up-newsletter-modal", visible: true)
      expect(page).to have_current_path decidim.new_user_registration_path
    end

    it "checks when clicking the checking button and user is created" do
      fill_registration_form(step: 1)
      click_button "Continue"
      fill_registration_form(step: 2)
      submit_form

      expect do
        click_button "Check and continue"
      end.to change(Decidim::User, :count).by(1)

      expect(page).to have_current_path(decidim.user_complete_registration_path)

      user = Decidim::User.last

      expect(user.newsletter_notifications_at).not_to be_nil
    end

    it "submit after modal has been opened and selected an option" do
      fill_registration_form(step: 1)
      click_button "Continue"
      fill_registration_form(step: 2)
      submit_form

      expect do
        click_button "Keep uncheck"
      end.to change(Decidim::User, :count).by(1)

      expect(page).to have_current_path(decidim.user_complete_registration_path)

      user = Decidim::User.last

      expect(user.newsletter_notifications_at).to be_nil
    end
  end

  context "when newsletter checkbox is checked but submit fails" do
    before do
      fill_registration_form(step: 1)
      fill_in :user_password_confirmation, with: "failure"
      click_button "Continue"

      fill_registration_form(step: 2)
      page.check("user_newsletter")
    end

    it "shows all registration fields" do
      submit_form

      expect(page).to have_content("Sign up to participate")
      expect(page).to have_field("user_email")
      expect(page).to have_field("user_password")
      expect(page).to have_field("user_password_confirmation")
      expect(page).to have_field("user_name")
      expect(page).to have_field("user_nickname")
    end

    it "keeps the user newsletter checkbox true value" do
      submit_form

      expect(page).to have_current_path decidim.user_registration_path
      expect(page).to have_field("user_newsletter", checked: true)
    end
  end

  context "when newsletter checkbox is checked and registration is successful" do
    before do
      fill_registration_form(step: 1)
      click_button "Continue"
      fill_registration_form(step: 2)
      page.check("user_newsletter")
    end

    it "creates the user" do
      expect do
        submit_form
      end.to change(Decidim::User, :count).by(1)

      expect(page).to have_current_path(decidim.user_complete_registration_path)

      user = Decidim::User.last

      expect(user.newsletter_notifications_at).not_to be_nil
    end
  end
end
