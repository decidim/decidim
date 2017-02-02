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
    context "using email and password" do
      it "creates a new User" do
        find(".sign-up-link").click

        within ".new_user" do
          fill_in :user_email, with: "user@example.org"
          fill_in :user_name, with: "Responsible Citizen"
          fill_in :user_password, with: "123456"
          fill_in :user_password_confirmation, with: "123456"
          check :user_tos_agreement
          find("*[type=submit]").click
        end

        expect(page).to have_content("confirmation link")
      end
    end

    context "using facebook" do
      let(:verified) { true }
      let(:omniauth_hash) {
        OmniAuth::AuthHash.new({
          provider: 'facebook',
          uid: '123545',
          info: {
            email: "user@from-facebook.com",
            name: "Facebook User"
          }
        })
      }

      before :each do
        OmniAuth.config.test_mode = true
        OmniAuth.config.mock_auth[:facebook] = omniauth_hash
      end

      after :each do
        OmniAuth.config.test_mode = false
        OmniAuth.config.mock_auth[:facebook] = nil
      end

      context "when the user has confirmed the email in facebook" do
        it "creates a new User without sending confirmation instructions" do
          find(".sign-up-link").click

          click_link "Sign in with Facebook"

          expect(page).to have_content("Successfully")
          expect_user_logged
        end
      end
    end

    context "using twitter" do
      let(:email) { nil }
      let(:omniauth_hash) {
        OmniAuth::AuthHash.new({
          provider: 'twitter',
          uid: '123545',
          info: {
            name: "Twitter User",
            email: email
          }
        })
      }

      before :each do
        OmniAuth.config.test_mode = true
        OmniAuth.config.mock_auth[:twitter] = omniauth_hash
      end

      after :each do
        OmniAuth.config.test_mode = false
        OmniAuth.config.mock_auth[:twitter] = nil
      end

      context "when the response doesn't include the email" do
        it "redirects the user to a finish signup page" do
          find(".sign-up-link").click

          click_link "Sign in with Twitter"

          expect(page).to have_content("Successfully")
          expect(page).to have_content("Please complete your profile")

          within ".new_user" do
            fill_in :user_email, with: "user@from-twitter.com"
            find("*[type=submit]").click
          end

          expect(page).to have_content("confirmation link")
        end

        context "and a user already exists with the given email" do
          it "doesn't allow it" do
            create(:user, :confirmed, email: "user@from-twitter.com", organization: organization)
            find(".sign-up-link").click

            click_link "Sign in with Twitter"

            expect(page).to have_content("Successfully")
            expect(page).to have_content("Please complete your profile")

            within ".new_user" do
              fill_in :user_email, with: "user@from-twitter.com"
              find("*[type=submit]").click
            end

            expect(page).to have_content("Please complete your profile")
            expect(page).to have_content("Another account is using the same email address")
          end
        end
      end

      context "when the response includes the email" do
        let(:email) { "user@from-twitter.com" }

        it "creates a new User" do
          find(".sign-up-link").click

          click_link "Sign in with Twitter"

          expect_user_logged
        end
      end
    end

    context "using google" do
      let(:omniauth_hash) {
        OmniAuth::AuthHash.new({
          provider: 'google_oauth2',
          uid: '123545',
          info: {
            name: "Google User",
            email: "user@from-google.com"
          }
        })
      }

      before :each do
        OmniAuth.config.test_mode = true
        OmniAuth.config.mock_auth[:google_oauth2] = omniauth_hash
      end

      after :each do
        OmniAuth.config.test_mode = false
        OmniAuth.config.mock_auth[:google_oauth2] = nil
      end

      it "creates a new User" do
        find(".sign-up-link").click

        click_link "Sign in with Google"

        expect_user_logged
      end
    end
  end

  describe "Sign Up as a organization" do
    it "creates a new User" do
      find(".sign-up-link").click

      within ".new_user" do
        choose "Organization/Collective"

        fill_in :user_email, with: "user@example.org"
        fill_in :user_name, with: "Responsible Citizen"
        fill_in :user_password, with: "123456"
        fill_in :user_password_confirmation, with: "123456"

        fill_in :user_user_group_name, with: "My organization"
        fill_in :user_user_group_document_number, with: "12345678Z"
        fill_in :user_user_group_phone, with: "333-333-3333"

        check :user_tos_agreement
        find("*[type=submit]").click
      end

      expect(page).to have_content("confirmation link")
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

    describe "Sign in" do
      it "authenticates an existing User" do
        find(".sign-in-link").click

        within ".new_user" do
          fill_in :user_email, with: user.email
          fill_in :user_password, with: "password1234"
          find("*[type=submit]").click
        end

        expect(page).to have_content("Signed in successfully")
        expect(page).to have_content(user.name)
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

    describe "Sign Out" do
      before do
        login_as user, scope: :user
        visit decidim.root_path
      end

      it "signs out the user" do
        within ".topbar__user__logged" do
          find("ul").hover
          find(".sign-out-link").click
        end

        expect(page).to have_content("Signed out successfully.")
        expect(page).not_to have_content(user.name)
      end
    end
  end

  context "When a user is already registered with a social provider" do
    let(:user) { create(:user, :confirmed, organization: organization) }
    let(:identity) { create(:identity, user: user, provider: "facebook", uid: "12345") }

    let(:omniauth_hash) {
        OmniAuth::AuthHash.new({
          provider: identity.provider,
          uid: identity.uid,
          info: {
            email: user.email,
            name: "Facebook User",
            verified: true
          }
        })
      }

    before :each do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:facebook] = omniauth_hash
    end

    after :each do
      OmniAuth.config.test_mode = false
      OmniAuth.config.mock_auth[:facebook] = nil
    end

    describe "Sign in" do
      it "authenticates an existing User" do
        find(".sign-in-link").click

        click_link "Sign in with Facebook"

        expect(page).to have_content("Successfully")
        expect(page).to have_content(user.name)
      end
    end
  end
end
