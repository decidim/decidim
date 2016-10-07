# frozen_string_literal: true
require "spec_helper"

describe "Authentication", type: :feature, perform_enqueued: true do
  let(:organization) { create(:organization) }
  let(:last_user) { Decidim::User.last }

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  describe "Sign Up" do
    it "creates a new User" do
      click_link "Register"

      within ".new_user" do
        fill_in :user_email, with: "user@example.org"
        fill_in :user_password, with: "123456"
        fill_in :user_password_confirmation, with: "123456"
        find("*[type=submit]").click
      end

      expect(page).to have_content("confirmation link")
      expect(emails.count).to eq(1)
      expect(last_user.email).to eq("user@example.org")
      expect(last_user.organization).to eq(organization)
    end
  end

  describe "Confirm email" do
    it "confirms the user" do
      create(:user, organization: organization)

      visit last_email_link

      expect(page).to have_content("successfully confirmed")
      expect(last_user).to be_confirmed
    end
  end

  describe "Resend confirmation instructions" do
    let(:user) { create(:user, organization: organization) }

    it "sends an email with the instructions" do
      visit decidim.new_user_confirmation_path

      within ".new_user" do
        fill_in :user_email, with: user.email
        find("*[type=submit]").click
      end

      expect(emails.count).to eq(2)
      expect(page).to have_content("receive an email with instructions")
    end
  end

  context "When a user is already registered" do
    let(:user) { create(:user, :confirmed, organization: organization) }

    describe "Log in" do
      it "authenticates an existing User" do
        visit decidim.new_user_session_path

        within ".new_user" do
          fill_in :user_email, with: user.email
          fill_in :user_password, with: "password1234"
          find("*[type=submit]").click
        end

        expect(page).to have_content("Signed in successfully")
      end
    end

    describe "Forgot password" do
      it "sends a password recovery email" do
        visit decidim.new_user_password_path

        within ".new_user" do
          fill_in :user_email, with: user.email
          find("*[type=submit]").click
        end

        expect(page).to have_content("reset your password")
        expect(emails.count).to eq(1)
      end
    end

    describe "Reset password" do
      before do
        user.send_reset_password_instructions
      end

      it "sets a new password for the user" do
        visit last_email_link

        within ".new_user" do
          fill_in :user_password, with: "123456"
          fill_in :user_password_confirmation, with: "123456"
          find("*[type=submit]").click
        end

        expect(page).to have_content("password has been changed successfully")
      end
    end
  end
end
