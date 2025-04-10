# frozen_string_literal: true

require "spec_helper"

describe "Authentication" do
  let(:organization) { create(:organization) }
  let(:last_user) { Decidim::User.last }
  let(:omniauth_secrets) do
    {
      facebook: {
        enabled: true,
        app_id: "fake-facebook-app-id",
        app_secret: "fake-facebook-app-secret",
        icon: "phone"
      },
      twitter: {
        enabled: true,
        api_key: "fake-twitter-api-key",
        api_secret: "fake-twitter-api-secret",
        icon: "phone"
      },
      google_oauth2: {
        enabled: true,
        client_id: nil,
        client_secret: nil,
        icon: "phone"
      }
    }
  end

  before do
    allow(Decidim).to receive(:omniauth_providers).and_return(omniauth_secrets)
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  describe "Create an account" do
    around do |example|
      perform_enqueued_jobs { example.run }
    end

    context "when using email and password" do
      it "creates a new User" do
        click_on "Create an account"

        within ".new_user" do
          fill_in :registration_user_email, with: "user@example.org"
          fill_in :registration_user_name, with: "Responsible Citizen"
          fill_in :registration_user_password, with: "DfyvHn425mYAy2HL"
          check :registration_user_tos_agreement
          check :registration_user_newsletter
          find("*[type=submit]").click
        end

        expect(page).to have_content("confirmation link")
      end
    end

    context "when using another language" do
      before do
        within_language_menu do
          click_on "Castellano"
        end
      end

      it "keeps the locale settings" do
        click_on("Crea una cuenta")

        within ".new_user" do
          fill_in :registration_user_email, with: "user@example.org"
          fill_in :registration_user_name, with: "Responsible Citizen"
          fill_in :registration_user_password, with: "DfyvHn425mYAy2HL"
          check :registration_user_tos_agreement
          check :registration_user_newsletter
          find("*[type=submit]").click
        end

        expect(page).to have_content("Se ha enviado un mensaje con un enlace de confirmación")
        expect(last_user.locale).to eq("es")
      end
    end

    context "when being a robot" do
      it "denies the sign up" do
        click_on "Create an account"

        within ".new_user" do
          page.execute_script("$($('.new_user > div > input')[0]).val('Ima robot :D')")
          fill_in :registration_user_email, with: "user@example.org"
          fill_in :registration_user_name, with: "Responsible Citizen"
          fill_in :registration_user_password, with: "DfyvHn425mYAy2HL"
          check :registration_user_tos_agreement
          check :registration_user_newsletter
          find("*[type=submit]").click
        end

        expect(page).to have_no_content("confirmation link")
      end
    end

    context "when using facebook" do
      let(:omniauth_hash) do
        OmniAuth::AuthHash.new(
          provider: "facebook",
          uid: "123545",
          info: {
            email: "user@from-facebook.com",
            nickname: "facebook_user",
            name: "Facebook User"
          }
        )
      end

      before do
        OmniAuth.config.test_mode = true
        OmniAuth.config.mock_auth[:facebook] = omniauth_hash
        OmniAuth.config.add_camelization "facebook", "FaceBook"
        OmniAuth.config.request_validation_phase = ->(env) {} if OmniAuth.config.respond_to?(:request_validation_phase)
      end

      after do
        OmniAuth.config.test_mode = false
        OmniAuth.config.mock_auth[:facebook] = nil
        OmniAuth.config.camelizations.delete("facebook")
      end

      context "when the user has confirmed the email in facebook" do
        it "creates a new User without sending confirmation instructions" do
          click_on "Create an account"

          find(".login__omniauth-button.login__omniauth-button--facebook").click

          check :registration_user_tos_agreement
          within "#omniauth-register-form" do
            click_on "Create an account"
          end
          click_on("Keep unchecked")

          expect(page).to have_content("Successfully")
          expect_user_logged
        end
      end

      it "sends a welcome notification" do
        click_on "Create an account"

        find(".login__omniauth-button.login__omniauth-button--facebook").click

        check :registration_user_tos_agreement
        check :registration_user_newsletter
        within "#omniauth-register-form" do
          click_on "Create an account"
        end

        within_user_menu do
          click_on "Notifications"
        end

        within "#notifications" do
          expect(page).to have_content("thanks for joining #{translated(organization.name)}")
        end

        expect(last_email_body).to include("thanks for joining #{translated(organization.name)}")
      end

      context "when user did not fill one of the fields" do
        let!(:omniauth_hash) do
          OmniAuth::AuthHash.new(
            provider: "developer",
            uid: "123545",
            info: {
              nickname: "developer_user",
              name: "Developer User"
            }
          )
        end

        it "has to complete the account profile" do
          within "#main-bar" do
            click_on("Log in")
          end

          find(".login__omniauth-button.login__omniauth-button--facebook").click
          expect(page).to have_content("Please complete your profile")
          expect(page).to have_content("cannot be blank")

          fill_in "Your email", with: "user@from-developer.com"
          page.find_by_id("registration_user_tos_agreement").check
          page.find_by_id("registration_user_newsletter").check
          click_on "Complete profile"

          expect(page).to have_content("A message with a confirmation link has been sent to your email address. Please follow the link to activate your account.")
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
            email:
          }
        )
      end

      before do
        OmniAuth.config.test_mode = true
        OmniAuth.config.mock_auth[:twitter] = omniauth_hash

        OmniAuth.config.add_camelization "twitter", "Twitter"
        OmniAuth.config.request_validation_phase = ->(env) {} if OmniAuth.config.respond_to?(:request_validation_phase)
      end

      after do
        OmniAuth.config.test_mode = false
        OmniAuth.config.mock_auth[:twitter] = nil
        OmniAuth.config.camelizations.delete("twitter")
      end

      context "when the response does not include the email" do
        it "redirects the user to a finish signup page" do
          click_on "Create an account"

          find(".login__omniauth-button--x").click

          expect(page).to have_content("Successfully")
          expect(page).to have_content("Please complete your profile")
          expect(page).to have_content("Please fill in the following form in order to complete the account creation")

          within ".new_user" do
            fill_in :registration_user_email, with: "user@from-twitter.com"
            find("*[type=submit]").click
          end
        end

        context "and a user already exists with the given email" do
          it "does not allow it" do
            create(:user, :confirmed, email: "user@from-twitter.com", organization:)
            click_on "Create an account"

            find(".login__omniauth-button--x").click

            expect(page).to have_content("Successfully")
            expect(page).to have_content("Please complete your profile")

            within ".new_user" do
              fill_in :registration_user_email, with: "user@from-twitter.com"
              check :registration_user_tos_agreement
              check :registration_user_newsletter
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
          click_on "Create an account"
          find(".login__omniauth-button.login__omniauth-button--x").click

          check :registration_user_tos_agreement
          check :registration_user_newsletter
          within "#omniauth-register-form" do
            click_on "Create an account"
          end

          expect_user_logged
        end

        it "sends a welcome notification" do
          click_on "Create an account"
          find(".login__omniauth-button.login__omniauth-button--x").click
          check :registration_user_tos_agreement
          check :registration_user_newsletter
          within "#omniauth-register-form" do
            click_on "Create an account"
          end

          within_user_menu do
            click_on "Notifications"
          end

          within "#notifications" do
            expect(page).to have_content("thanks for joining #{translated(organization.name)}")
          end

          expect(last_email_body).to include("thanks for joining #{translated(organization.name)}")
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
            nickname: "google_user",
            email: "user@from-google.com"
          }
        )
      end

      before do
        OmniAuth.config.test_mode = true
        OmniAuth.config.mock_auth[:google_oauth2] = omniauth_hash

        OmniAuth.config.add_camelization "google_oauth2", "GoogleOauth"
        OmniAuth.config.request_validation_phase = ->(env) {} if OmniAuth.config.respond_to?(:request_validation_phase)
      end

      after do
        OmniAuth.config.test_mode = false
        OmniAuth.config.mock_auth[:google_oauth2] = nil
        OmniAuth.config.camelizations.delete("google_oauth2")
      end

      it "creates a new User" do
        click_on "Create an account"

        click_on "Log in with Google"
        check :registration_user_tos_agreement
        check :registration_user_newsletter
        within "#omniauth-register-form" do
          click_on "Create an account"
        end

        expect_user_logged
      end

      it "sends a welcome notification" do
        click_on "Create an account"

        click_on "Log in with Google"
        check :registration_user_tos_agreement
        check :registration_user_newsletter
        within "#omniauth-register-form" do
          click_on "Create an account"
        end

        within_user_menu do
          click_on "Notifications"
        end

        within "#notifications" do
          expect(page).to have_content("thanks for joining #{translated(organization.name)}")
        end

        expect(last_email_body).to include("thanks for joining #{translated(organization.name)}")
      end
    end

    context "when nickname is not unique" do
      let!(:user) { create(:user, nickname: "responsible_citizen", organization:) }

      it "creates a new User" do
        click_on "Create an account"

        within ".new_user" do
          fill_in :registration_user_email, with: "user@example.org"
          fill_in :registration_user_name, with: "Responsible Citizen"
          fill_in :registration_user_password, with: "DfyvHn425mYAy2HL"
          check :registration_user_tos_agreement
          check :registration_user_newsletter
          find("*[type=submit]").click
        end

        expect(page).to have_content("confirmation link")
        expect(last_user.nickname).to eq("responsible_citize_2")
      end
    end

    context "when sign up is disabled" do
      let(:organization) { create(:organization, users_registration_mode: :existing) }

      it "redirects to the sign in when accessing the sign up page" do
        visit decidim.new_user_registration_path
        expect(page).to have_no_content("Create an account")
      end

      it "do not allow the user to sign up" do
        click_on("Log in", match: :first)
        expect(page).to have_no_content("Create an account")
      end
    end
  end

  describe "Confirm email" do
    it "confirms and logs in the user" do
      perform_enqueued_jobs { create(:user, organization:) }

      visit last_email_link

      expect(page).to have_content("successfully confirmed")
      expect(last_user).to be_confirmed

      within_user_menu do
        expect(page).to have_content("My account")
        expect(page).to have_content("Log out")
      end
    end
  end

  context "when confirming the account" do
    let!(:user) { create(:user, organization:) }

    before do
      perform_enqueued_jobs { user.confirm }
      switch_to_host(user.organization.host)
      login_as user, scope: :user
      # Prevent flaky spec where user is not logged in
      sleep 1
      visit decidim.root_path
    end

    it "sends a welcome notification" do
      within_user_menu do
        click_on "Notifications"
      end

      within "#notifications" do
        expect(page).to have_content("thanks for joining #{translated(organization.name)}")
      end

      expect(last_email_body).to include("thanks for joining #{translated(organization.name)}")
    end
  end

  describe "Resend confirmation instructions" do
    let(:user) do
      perform_enqueued_jobs { create(:user, organization:) }
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
    let(:user) { create(:user, :confirmed, password: "DfyvHn425mYAy2HL", organization:) }

    describe "Log in" do
      it "authenticates an existing User" do
        click_on("Log in", match: :first)

        within ".new_user" do
          fill_in :session_user_email, with: user.email
          fill_in :session_user_password, with: "DfyvHn425mYAy2HL"
          find("*[type=submit]").click
        end

        expect(page).to have_content("Logged in successfully")
        expect_current_user_to_be(user)
      end

      context "when email validation is triggered in the log in form" do
        before do
          click_on("Log in", match: :first)
        end

        context "when focus shifts to password" do
          it "displays error when email is empty" do
            within "#session_new_user" do
              fill_in :session_user_email, with: ""
              find_by_id("session_user_password").click
            end

            expect(page).to have_css(".form-error.is-visible", text: "There is an error in this field.")
          end

          it "displays error when email is invalid" do
            within "#session_new_user" do
              fill_in :session_user_email, with: "invalid-email"
              find_by_id("session_user_password").click
            end

            expect(page).to have_css(".form-error.is-visible", text: "There is an error in this field")
          end
        end

        context "when focus remains on email" do
          it "does not display error when email is empty" do
            within "#session_new_user" do
              fill_in :session_user_email, with: ""
              find_by_id("session_user_email").click
            end

            expect(page).to have_no_css(".form-error.is-visible", text: "There is an error in this field.")
          end

          it "does not display error when email is invalid" do
            within "#session_new_user" do
              fill_in :session_user_email, with: "invalid-email"
              find_by_id("session_user_email").click
            end

            expect(page).to have_no_css(".form-error.is-visible", text: "There is an error in this field")
          end
        end
      end

      it "caches the omniauth buttons correctly with different languages", :caching do
        click_on("Log in", match: :first)
        expect(page).to have_link("Log in with Facebook")

        within_language_menu do
          click_on "Català"
        end
      end
    end

    describe "Forgot password" do
      it "sends a password recovery email" do
        visit decidim.new_user_password_path

        within ".new_user" do
          fill_in :password_user_email, with: user.email
          perform_enqueued_jobs { find("*[type=submit]").click }
        end

        expect(page).to have_content("If your email address exists in our database")
        expect(emails.count).to eq(1)
      end

      it "says it sends a password recovery email when is a non-existing email" do
        visit decidim.new_user_password_path

        within ".new_user" do
          fill_in :password_user_email, with: "nonexistent@example.org"
          find("*[type=submit]").click
        end

        expect(page).to have_content("If your email address exists in our database")
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
          find("*[type=submit]").click
        end

        expect(page).to have_content("Your password has been successfully changed")
        expect(page).to have_current_path "/"
      end

      it "enforces rules when setting a new password for the user" do
        visit last_email_link

        within ".new_user" do
          fill_in :password_user_password, with: "whatislove"
          find("*[type=submit]").click
        end

        expect(page).to have_content("10 characters minimum")
        expect(page).to have_content("must be different from your nickname and your email")
        expect(page).to have_content("must not be too common")
        expect(page).to have_current_path "/users/password"
      end

      it "enforces the minimum length for the password in the front-end" do
        visit last_email_link

        within ".new_user" do
          fill_in :password_user_password, with: "example"
          find("*[type=submit]").click
        end

        expect(page).to have_content("The password is too short.")
      end
    end

    describe "Log Out" do
      before do
        login_as user, scope: :user
        # Prevent flaky spec where user is not logged in
        sleep 1
        visit decidim.root_path
      end

      it "logs out the user" do
        within_user_menu do
          click_on("Log out")
        end

        expect(page).to have_content("Logged out successfully.")
        expect(page).to have_no_content(user.name)
      end
    end

    context "with lockable account" do
      Devise.maximum_attempts = 3
      let!(:maximum_attempts) { Devise.maximum_attempts }

      describe "when attempting to log in with failing password" do
        describe "before locking" do
          before do
            visit decidim.root_path
            click_on("Log in", match: :first)

            (maximum_attempts - 2).times do
              within ".new_user" do
                fill_in :session_user_email, with: user.email
                fill_in :session_user_password, with: "not-the-password"
                find("*[type=submit]").click
              end
            end
          end

          it "does not show the last attempt warning before locking the account" do
            within ".new_user" do
              fill_in :session_user_email, with: user.email
              fill_in :session_user_password, with: "not-the-password"
              find("*[type=submit]").click
            end

            expect(page).to have_content("Invalid")
          end
        end

        describe "locks the account" do
          before do
            visit decidim.root_path
            click_on("Log in", match: :first)

            (maximum_attempts - 1).times do
              within ".new_user" do
                fill_in :session_user_email, with: user.email
                fill_in :session_user_password, with: "not-the-password"
                find("*[type=submit]").click
              end
            end
          end

          it "when reached maximum failed attempts" do
            within ".new_user" do
              fill_in :session_user_email, with: user.email
              fill_in :session_user_password, with: "not-the-password"
              perform_enqueued_jobs { find("*[type=submit]").click }
            end

            expect(page).to have_content("Invalid")
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

          expect(page).to have_content("If your account exists")
          expect(emails.count).to eq(1)
        end

        it "says it resends the unlock instructions when is a non-existing user account" do
          within ".new_user" do
            fill_in :unlock_user_email, with: user.email
            find("*[type=submit]").click
          end

          expect(page).to have_content("If your account exists")
        end
      end

      describe "Unlock account" do
        before do
          user.lock_access!
          perform_enqueued_jobs { user.send_unlock_instructions }
        end

        it "unlocks the user account" do
          visit last_email_link

          expect(page).to have_content("Your account has been successfully unlocked. Please log in to continue")
        end
      end
    end
  end

  context "when a user is already registered with a social provider" do
    let(:user) { create(:user, :confirmed, organization:) }
    let(:identity) { create(:identity, user:, provider: "facebook", uid: "12345") }

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
      OmniAuth.config.add_camelization "facebook", "FaceBook"
      OmniAuth.config.request_validation_phase = ->(env) {} if OmniAuth.config.respond_to?(:request_validation_phase)
    end

    after do
      OmniAuth.config.test_mode = false
      OmniAuth.config.mock_auth[:facebook] = nil
      OmniAuth.config.camelizations.delete("facebook")
    end

    describe "Log in" do
      it "authenticates an existing User" do
        click_on("Log in", match: :first)

        find(".login__omniauth-button.login__omniauth-button--facebook").click

        expect(page).to have_content("Successfully")
        expect_current_user_to_be(user)
      end

      context "when sign up is disabled" do
        let(:organization) { create(:organization, users_registration_mode: :existing) }

        it "does not allow the user to sign up" do
          click_on("Log in", match: :first)
          expect(page).to have_no_content("Create an account")
        end
      end

      context "when sign in is disabled" do
        let(:organization) { create(:organization, users_registration_mode: :disabled) }

        it "does not allow the user to sign up" do
          click_on("Log in", match: :first)
          expect(page).to have_no_content("Create an account")
        end

        it "does not allow the user to sign in as a regular user, only through external accounts" do
          click_on("Log in", match: :first)
          expect(page).to have_no_content("Email")
          within("div.login__omniauth") do
            expect(page).to have_link("Facebook")
          end
        end

        it "authenticates an existing User" do
          click_on("Log in", match: :first)

          find(".login__omniauth-button.login__omniauth-button--facebook").click

          expect(page).to have_content("Successfully")
          expect_current_user_to_be(user)
        end

        context "when admin password is expired" do
          let(:user) { create(:user, :confirmed, :admin, password_updated_at: 91.days.ago, organization:) }

          before do
            allow(Decidim.config).to receive(:admin_password_expiration_days).and_return(90)
          end

          it "can log in without being prompted to change the password" do
            click_on("Log in", match: :first)
            click_on "Log in with Facebook"
            expect(page).to have_content("Successfully")
          end
        end
      end
    end
  end

  context "when a user is already registered in another organization with the same email" do
    let(:user) { create(:user, :confirmed, password: "DfyvHn425mYAy2HL") }

    describe "Create an account" do
      context "when using the same email" do
        it "creates a new User" do
          click_on "Create an account"

          within ".new_user" do
            fill_in :registration_user_email, with: user.email
            fill_in :registration_user_name, with: "Responsible Citizen"
            fill_in :registration_user_password, with: "DfyvHn425mYAy2HL"
            check :registration_user_tos_agreement
            check :registration_user_newsletter
            find("*[type=submit]").click
          end

          expect(page).to have_content("confirmation link")
        end
      end
    end
  end

  context "when a user is already registered in another organization with the same fb account" do
    let(:user) { create(:user, :confirmed) }
    let(:identity) { create(:identity, user:, provider: "facebook", uid: "12345") }

    let(:omniauth_hash) do
      OmniAuth::AuthHash.new(
        provider: identity.provider,
        uid: identity.uid,
        info: {
          email: user.email,
          name: "Facebook User",
          nickname: "facebook_user",
          verified: true
        }
      )
    end

    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:facebook] = omniauth_hash
      OmniAuth.config.add_camelization "facebook", "FaceBook"
      OmniAuth.config.request_validation_phase = ->(env) {} if OmniAuth.config.respond_to?(:request_validation_phase)
    end

    after do
      OmniAuth.config.test_mode = false
      OmniAuth.config.mock_auth[:facebook] = nil
      OmniAuth.config.camelizations.delete("facebook")
    end

    describe "Create an account" do
      context "when the user has confirmed the email in facebook" do
        it "creates a new User without sending confirmation instructions" do
          click_on "Create an account"

          find(".login__omniauth-button.login__omniauth-button--facebook").click

          expect(page).to have_content("Finish creating your account")

          check :registration_user_tos_agreement
          check :registration_user_newsletter
          within "#omniauth-register-form" do
            click_on "Create an account"
          end
          expect_user_logged
        end
      end
    end
  end

  context "when a user with the same email is already registered in another organization" do
    let(:organization2) { create(:organization) }

    let!(:user2) { create(:user, :confirmed, email: "fake@user.com", name: "Wrong user", organization: organization2, password: "DfyvHn425mYAy2HL") }
    let!(:user) { create(:user, :confirmed, email: "fake@user.com", name: "Right user", organization:, password: "DfyvHn425mYAy2HL") }

    describe "Log in" do
      it "authenticates the right user" do
        click_on("Log in", match: :first)

        within ".new_user" do
          fill_in :session_user_email, with: user.email
          fill_in :session_user_password, with: "DfyvHn425mYAy2HL"
          find("*[type=submit]").click
        end

        expect(page).to have_content("successfully")
        expect_current_user_to_be(user)
        expect(page).to have_no_content("Wrong user")
      end
    end
  end
end

def expect_current_user_to_be(user)
  within_user_menu do
    click_on "My public profile"
  end
  expect(page).to have_content(user.name)
end
