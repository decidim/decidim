# frozen_string_literal: true

require "spec_helper"

describe "Authentication", type: :system do
  let(:organization) { create(:organization) }
  let(:last_user) { Decidim::User.last }

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  describe "Sign Up" do
    context "when using email and password" do
      it "creates a new User" do
        find(".sign-up-link").click

        within ".new_user" do
          fill_in :registration_user_email, with: "user@example.org"
          fill_in :registration_user_name, with: "Responsible Citizen"
          fill_in :registration_user_nickname, with: "responsible"
          fill_in :registration_user_password, with: "DfyvHn425mYAy2HL"
          fill_in :registration_user_password_confirmation, with: "DfyvHn425mYAy2HL"
          check :registration_user_tos_agreement
          check :registration_user_newsletter
          find("*[type=submit]").click
        end

        expect(page).to have_content("You have signed up successfully")
      end
    end

    context "when using another langage" do
      before do
        within_language_menu do
          click_link "Castellano"
        end
      end

      it "keeps the locale settings" do
        find(".sign-up-link").click

        within ".new_user" do
          fill_in :registration_user_email, with: "user@example.org"
          fill_in :registration_user_name, with: "Responsible Citizen"
          fill_in :registration_user_nickname, with: "responsible"
          fill_in :registration_user_password, with: "DfyvHn425mYAy2HL"
          fill_in :registration_user_password_confirmation, with: "DfyvHn425mYAy2HL"
          check :registration_user_tos_agreement
          check :registration_user_newsletter
          find("*[type=submit]").click
        end

        expect(page).to have_content("¡Bienvenida! Te has registrado con éxito.")
        expect(last_user.locale).to eq("es")
      end
    end

    context "when being a robot" do
      it "denies the sign up" do
        find(".sign-up-link").click

        within ".new_user" do
          page.execute_script("$($('.new_user > div > input')[0]).val('Ima robot :D')")
          fill_in :registration_user_email, with: "user@example.org"
          fill_in :registration_user_name, with: "Responsible Citizen"
          fill_in :registration_user_nickname, with: "responsible"
          fill_in :registration_user_password, with: "DfyvHn425mYAy2HL"
          fill_in :registration_user_password_confirmation, with: "DfyvHn425mYAy2HL"
          check :registration_user_tos_agreement
          check :registration_user_newsletter
          find("*[type=submit]").click
        end

        expect(page).not_to have_content("You have signed up successfully")
      end
    end

    context "when using facebook" do
      let(:omniauth_hash) do
        OmniAuth::AuthHash.new(
          provider: "facebook",
          uid: "123545",
          info: {
            email: "user@from-facebook.com",
            name: "Facebook User"
          }
        )
      end

      before do
        OmniAuth.config.test_mode = true
        OmniAuth.config.mock_auth[:facebook] = omniauth_hash
      end

      after do
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

    context "when using twitter" do
      let(:email) { nil }
      let(:omniauth_hash) do
        OmniAuth::AuthHash.new(
          provider: "twitter",
          uid: "123545",
          info: {
            name: "Twitter User",
            nickname: "twitter_user",
            email: email
          }
        )
      end

      before do
        OmniAuth.config.test_mode = true
        OmniAuth.config.mock_auth[:twitter] = omniauth_hash
      end

      after do
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
            fill_in :registration_user_email, with: "user@from-twitter.com"
            find("*[type=submit]").click
          end
        end

        context "and a user already exists with the given email" do
          it "doesn't allow it" do
            create(:user, :confirmed, email: "user@from-twitter.com", organization: organization)
            find(".sign-up-link").click

            click_link "Sign in with Twitter"

            expect(page).to have_content("Successfully")
            expect(page).to have_content("Please complete your profile")

            within ".new_user" do
              fill_in :registration_user_email, with: "user@from-twitter.com"
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

    context "when using google" do
      let(:omniauth_hash) do
        OmniAuth::AuthHash.new(
          provider: "google_oauth2",
          uid: "123545",
          info: {
            name: "Google User",
            email: "user@from-google.com"
          }
        )
      end

      before do
        OmniAuth.config.test_mode = true
        OmniAuth.config.mock_auth[:google_oauth2] = omniauth_hash
      end

      after do
        OmniAuth.config.test_mode = false
        OmniAuth.config.mock_auth[:google_oauth2] = nil
      end

      it "creates a new User" do
        find(".sign-up-link").click

        click_link "Sign in with Google"

        expect_user_logged
      end
    end

    context "when sign up is disabled" do
      let(:organization) { create(:organization, users_registration_mode: :existing) }

      it "redirects to the sign in when accessing the sign up page" do
        visit decidim.new_user_registration_path
        expect(page).not_to have_content("Sign Up")
      end

      it "don't allow the user to sign up" do
        find(".sign-in-link").click
        expect(page).not_to have_content("Create an account")
      end
    end
  end

  describe "Confirm email" do
    it "confirms the user" do
      perform_enqueued_jobs { create(:user, organization: organization) }

      visit last_email_link

      expect(page).to have_content("successfully confirmed")
      expect(last_user).to be_confirmed
    end
  end

  context "when confirming the account" do
    let!(:user) { create(:user, email_on_notification: true, organization: organization) }

    before do
      perform_enqueued_jobs { user.confirm }
      switch_to_host(user.organization.host)
      login_as user, scope: :user
      visit decidim.root_path
    end

    it "sends a welcome notification" do
      find("a.topbar__notifications").click

      within "#notifications" do
        expect(page).to have_content("Welcome")
        expect(page).to have_content("thanks for joining #{organization.name}")
      end

      expect(last_email_body).to include("thanks for joining #{organization.name}")
    end
  end

  describe "Resend confirmation instructions" do
    let(:user) do
      perform_enqueued_jobs { create(:user, organization: organization) }
    end

    it "sends an email with the instructions" do
      visit decidim.new_user_confirmation_path

      within ".new_user" do
        fill_in :confirmation_user_email, with: user.email
        perform_enqueued_jobs { find("*[type=submit]").click }
      end

      expect(emails.count).to eq(2)
      expect(page).to have_content("receive an email with instructions")
    end
  end

  context "when a user is already registered" do
    let(:user) { create(:user, :confirmed, password: "DfyvHn425mYAy2HL", organization: organization) }

    describe "Sign in" do
      it "authenticates an existing User" do
        find(".sign-in-link").click

        within ".new_user" do
          fill_in :session_user_email, with: user.email
          fill_in :session_user_password, with: "DfyvHn425mYAy2HL"
          find("*[type=submit]").click
        end

        expect(page).to have_content("Signed in successfully")
        expect(page).to have_content(user.name)
      end

      it "caches the omniauth buttons correctly with different languages", :caching do
        find(".sign-in-link").click
        expect(page).to have_content("Sign in with Facebook")

        within_language_menu do
          click_link "Català"
        end

        expect(page).to have_content("Inicia sessió amb Facebook")
      end
    end

    describe "Forgot password" do
      it "sends a password recovery email" do
        visit decidim.new_user_password_path

        within ".new_user" do
          fill_in :password_user_email, with: user.email
          perform_enqueued_jobs { find("*[type=submit]").click }
        end

        expect(page).to have_content("reset your password")
        expect(emails.count).to eq(1)
      end
    end

    describe "Reset password" do
      before do
        perform_enqueued_jobs { user.send_reset_password_instructions }
      end

      it "sets a new password for the user" do
        visit last_email_link

        within ".new_user" do
          fill_in :password_user_password, with: "DfyvHn425mYAy2HL"
          fill_in :password_user_password_confirmation, with: "DfyvHn425mYAy2HL"
          find("*[type=submit]").click
        end

        expect(page).to have_content("Your password has been successfully changed")
        expect(page).to have_current_path "/"
      end
    end

    describe "Sign Out" do
      before do
        login_as user, scope: :user
        visit decidim.root_path
      end

      it "signs out the user" do
        within_user_menu do
          find(".sign-out-link").click
        end

        expect(page).to have_content("Signed out successfully.")
        expect(page).to have_no_content(user.name)
      end
    end

    context "with lockable account" do
      Devise.maximum_attempts = 3
      let!(:maximum_attempts) { Devise.maximum_attempts }

      describe "when attempting to login with failing password" do
        describe "before locking" do
          before do
            visit decidim.root_path
            find(".sign-in-link").click

            (maximum_attempts - 2).times do
              within ".new_user" do
                fill_in :session_user_email, with: user.email
                fill_in :session_user_password, with: "not-the-pasword"
                find("*[type=submit]").click
              end
            end
          end

          it "shows the last attempt warning before locking the account" do
            within ".new_user" do
              fill_in :session_user_email, with: user.email
              fill_in :session_user_password, with: "not-the-pasword"
              find("*[type=submit]").click
            end

            expect(page).to have_content("You have one more attempt before your account is locked.")
          end
        end

        describe "locks the account" do
          before do
            visit decidim.root_path
            find(".sign-in-link").click

            (maximum_attempts - 1).times do
              within ".new_user" do
                fill_in :session_user_email, with: user.email
                fill_in :session_user_password, with: "not-the-pasword"
                find("*[type=submit]").click
              end
            end
          end

          it "when reached maximum failed attempts" do
            within ".new_user" do
              fill_in :session_user_email, with: user.email
              fill_in :session_user_password, with: "not-the-pasword"
              perform_enqueued_jobs { find("*[type=submit]").click }
            end

            expect(page).to have_content("Your account is locked.")
            expect(emails.count).to eq(1)
          end
        end
      end

      describe "Resend unlock instructions email" do
        before do
          user.lock_access!

          visit decidim.new_user_unlock_path
        end

        it "resends the unlock instructions" do
          within ".new_user" do
            fill_in :unlock_user_email, with: user.email
            perform_enqueued_jobs { find("*[type=submit]").click }
          end

          expect(page).to have_content("You will receive an email with instructions for how to unlock your account in a few minutes.")
          expect(emails.count).to eq(1)
        end
      end

      describe "Unlock account" do
        before do
          user.lock_access!
          perform_enqueued_jobs { user.send_unlock_instructions }
        end

        it "unlocks the user account" do
          visit last_email_link

          expect(page).to have_content("Your account has been successfully unlocked. Please sign in to continue")
        end
      end
    end
  end

  context "when a user is already registered with a social provider" do
    let(:user) { create(:user, :confirmed, organization: organization) }
    let(:identity) { create(:identity, user: user, provider: "facebook", uid: "12345") }

    let(:omniauth_hash) do
      OmniAuth::AuthHash.new(
        provider: identity.provider,
        uid: identity.uid,
        info: {
          email: user.email,
          name: "Facebook User",
          verified: true
        }
      )
    end

    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:facebook] = omniauth_hash
    end

    after do
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

      context "when sign up is disabled" do
        let(:organization) { create(:organization, users_registration_mode: :existing) }

        it "doesn't allow the user to sign up" do
          find(".sign-in-link").click
          expect(page).not_to have_content("Sign Up")
        end
      end

      context "when sign in is disabled" do
        let(:organization) { create(:organization, users_registration_mode: :disabled) }

        it "doesn't allow the user to sign up" do
          find(".sign-in-link").click
          expect(page).not_to have_content("Sign Up")
        end

        it "doesn't allow the user to sign in as a regular user, only through external accounts" do
          find(".sign-in-link").click
          expect(page).not_to have_content("Email")
          expect(page).to have_css(".button--facebook")
        end

        it "authenticates an existing User" do
          find(".sign-in-link").click

          click_link "Sign in with Facebook"

          expect(page).to have_content("Successfully")
          expect(page).to have_content(user.name)
        end
      end
    end
  end

  context "when a user is already registered in another organization with the same email" do
    let(:user) { create(:user, :confirmed, password: "DfyvHn425mYAy2HL") }

    describe "Sign Up" do
      context "when using the same email" do
        it "creates a new User" do
          find(".sign-up-link").click

          within ".new_user" do
            fill_in :registration_user_email, with: user.email
            fill_in :registration_user_name, with: "Responsible Citizen"
            fill_in :registration_user_nickname, with: "responsible"
            fill_in :registration_user_password, with: "DfyvHn425mYAy2HL"
            fill_in :registration_user_password_confirmation, with: "DfyvHn425mYAy2HL"
            check :registration_user_tos_agreement
            check :registration_user_newsletter
            find("*[type=submit]").click
          end

          expect(page).to have_content("You have signed up successfully")
        end
      end
    end
  end

  context "when a user is already registered in another organization with the same fb account" do
    let(:user) { create(:user, :confirmed) }
    let(:identity) { create(:identity, user: user, provider: "facebook", uid: "12345") }

    let(:omniauth_hash) do
      OmniAuth::AuthHash.new(
        provider: identity.provider,
        uid: identity.uid,
        info: {
          email: user.email,
          name: "Facebook User",
          verified: true
        }
      )
    end

    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:facebook] = omniauth_hash
    end

    after do
      OmniAuth.config.test_mode = false
      OmniAuth.config.mock_auth[:facebook] = nil
    end

    describe "Sign Up" do
      context "when the user has confirmed the email in facebook" do
        it "creates a new User without sending confirmation instructions" do
          find(".sign-up-link").click

          click_link "Sign in with Facebook"

          expect(page).to have_content("Successfully")
          expect_user_logged
        end
      end
    end
  end

  context "when a user with the same email is already registered in another organization" do
    let(:organization2) { create(:organization) }

    let!(:user2) { create(:user, :confirmed, email: "fake@user.com", name: "Wrong user", organization: organization2, password: "DfyvHn425mYAy2HL") }
    let!(:user) { create(:user, :confirmed, email: "fake@user.com", name: "Right user", organization: organization, password: "DfyvHn425mYAy2HL") }

    describe "Sign in" do
      it "authenticates the right user" do
        find(".sign-in-link").click

        within ".new_user" do
          fill_in :session_user_email, with: user.email
          fill_in :session_user_password, with: "DfyvHn425mYAy2HL"
          find("*[type=submit]").click
        end

        expect(page).to have_content("successfully")
        expect(page).to have_content("Right user")
      end
    end
  end
end
