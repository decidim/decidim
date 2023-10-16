# frozen_string_literal: true

require "spec_helper"

describe "Account", type: :system do
  let(:user) { create(:user, :confirmed, password:) }
  let(:password) { "dqCFgjfDbC7dPbrv" }
  let(:organization) { user.organization }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  describe "navigation" do
    it "shows the account form when clicking on the menu" do
      visit decidim.root_path

      within_user_menu do
        find("a", text: "account").click
      end

      expect(page).to have_css("form.edit_user")
    end
  end

  context "when on the account page" do
    before do
      visit decidim.account_path
    end

    it_behaves_like "accessible page"

    describe "update avatar" do
      it "can update avatar" do
        dynamically_attach_file(:user_avatar, Decidim::Dev.asset("avatar.jpg"), remove_before: true)

        within "form.edit_user" do
          find("*[type=submit]").click
        end

        expect(page).to have_css(".flash.success")
      end

      it "shows error when image is too big" do
        find("#user_avatar_button").click

        within ".upload-modal" do
          click_button "Remove"
          input_element = find("input[type='file']", visible: :all)
          input_element.attach_file(Decidim::Dev.asset("5000x5000.png"))

          expect(page).to have_content("File resolution is too large", count: 1)
          expect(page).to have_content("Validation error!")
        end
      end
    end

    describe "updating personal data" do
      let!(:encrypted_password) { user.encrypted_password }

      it "updates the user's data" do
        within "form.edit_user" do
          select "Castellano", from: :user_locale
          fill_in :user_name, with: "Nikola Tesla"
          fill_in :user_personal_url, with: "https://example.org"
          fill_in :user_about, with: "A Serbian-American inventor, electrical engineer, mechanical engineer, physicist, and futurist."
          find("*[type=submit]").click
        end

        within_flash_messages do
          expect(page).to have_content("successfully")
        end

        user.reload

        within_user_menu do
          find("a", text: "perfil público").click
        end

        expect(page).to have_content("example.org")
        expect(page).to have_content("Serbian-American")

        # The user's password should not change when they did not update it
        expect(user.reload.encrypted_password).to eq(encrypted_password)
      end
    end

    context "when updating the email" do
      let(:pending_email) { "foo@bar.com" }

      before do
        within "form.edit_user" do
          fill_in :user_email, with: pending_email

          perform_enqueued_jobs { find("*[type=submit]").click }
        end

        within_flash_messages do
          expect(page).to have_content("You will receive an email to confirm your new email address")
        end
      end

      after do
        clear_enqueued_jobs
      end

      it "tells user to confirm new email" do
        expect(page).to have_content("Email change verification")
        expect(page).to have_selector("#user_email[disabled='disabled']")
        expect(page).to have_content("We have sent an email to #{pending_email} to verify your new email address")
      end

      it "resend confirmation" do
        within "#email-change-pending" do
          click_link "Send again"
        end
        expect(page).to have_content("Confirmation email resent successfully to #{pending_email}")
        perform_enqueued_jobs
        perform_enqueued_jobs

        expect(emails.count).to eq(3)
        visit last_email_link
        expect(page).to have_content("Your email address has been successfully confirmed")
      end

      it "cancels the email change" do
        expect(Decidim::User.find(user.id).unconfirmed_email).to eq(pending_email)
        within "#email-change-pending" do
          click_link "cancel"
        end

        expect(page).to have_content("Email change cancelled successfully")
        expect(page).not_to have_content("Email change verification")
        expect(Decidim::User.find(user.id).unconfirmed_email).to be_nil
      end
    end

    context "when on the notifications settings page" do
      before do
        visit decidim.notifications_settings_path
      end

      it "updates the user's notifications" do
        page.find("[for='newsletter_notifications']").click

        within "form.edit_user" do
          find("*[type=submit]").click
        end

        within_flash_messages do
          expect(page).to have_content("successfully")
        end
      end

      context "when the user is an admin" do
        let!(:user) { create(:user, :confirmed, :admin, password:) }

        before do
          login_as user, scope: :user
          visit decidim.notifications_settings_path
        end

        it "updates the administrator's notifications" do
          page.find("[for='email_on_moderations']").click
          page.find("[for='user_notification_settings[close_meeting_reminder]']").click

          within "form.edit_user" do
            find("*[type=submit]").click
          end

          within_flash_messages do
            expect(page).to have_content("successfully")
          end
        end
      end
    end

    context "when on the interests page" do
      before do
        visit decidim.user_interests_path
      end

      it "does not find any scopes" do
        expect(page).to have_content("My interests")
        expect(page).to have_content("This organization does not have any scope yet")
      end

      context "when scopes are defined" do
        let!(:scopes) { create_list(:scope, 3, organization:) }
        let!(:subscopes) { create_list(:subscope, 3, parent: scopes.first) }

        before do
          visit decidim.user_interests_path
        end

        it "display translated scope name" do
          expect(page).to have_content("My interests")
          within "label[for='user_scopes_#{scopes.first.id}_checked']" do
            expect(page).to have_content(translated(scopes.first.name))
          end
        end

        it "allows to choose interests" do
          label_field = "label[for='user_scopes_#{scopes.first.id}_checked']"
          expect(page).to have_content("My interests")
          find(label_field).click
          click_button "Update my interests"

          within_flash_messages do
            expect(page).to have_content("Your interests have been successfully updated.")
          end
        end
      end
    end

    context "when on the delete my account page" do
      before do
        visit decidim.delete_account_path
      end

      it "does not display the authorizations message by default" do
        expect(page).not_to have_content("Some data bound to your authorization will be saved for security.")
      end

      it "the user can delete their account" do
        fill_in :delete_user_delete_account_delete_reason, with: "I just want to delete my account"

        click_button "Delete my account"

        click_button "Yes, I want to delete my account"

        within_flash_messages do
          expect(page).to have_content("successfully")
        end

        click_link("Log in", match: :first)

        within ".new_user" do
          fill_in :session_user_email, with: user.email
          fill_in :session_user_password, with: password
          find("*[type=submit]").click
        end

        expect(page).not_to have_content("Signed in successfully")
        expect(page).not_to have_content(user.name)
      end

      context "when the user has an authorization" do
        let!(:authorization) { create(:authorization, :granted, user:) }

        it "displays the authorizations message" do
          visit decidim.delete_account_path

          expect(page).to have_content("Some data bound to your authorization will be saved for security.")
        end
      end
    end
  end

  context "when on the notifications page in a PWA browser" do
    let(:organization) { create(:organization, host: "pwa.lvh.me") }
    let(:user) { create(:user, :confirmed, password:, organization:) }
    let(:password) { "dqCFgjfDbC7dPbrv" }
    let(:vapid_keys) do
      {
        enabled: true,
        public_key: "BKmjw_A8tJCcZNQ72uG8QW15XHQnrGJjHjsmoUILUUFXJ1VNhOnJLc3ywR3eZKibX4HSqhB1hAzZFj__3VqzcPQ=",
        private_key: "TF_MRbSSs_4BE1jVfOsILSJemND8cRMpiznWHgdsro0="
      }
    end

    context "when VAPID keys are set" do
      before do
        Rails.application.secrets[:vapid] = vapid_keys
        driven_by(:pwa_chrome)
        switch_to_host(organization.host)
        login_as user, scope: :user
        visit decidim.notifications_settings_path
      end

      context "when on the account page" do
        it "enables push notifications if supported browser" do
          sleep 2
          page.find("[for='allow_push_notifications']").click

          # Wait for the browser to be subscribed
          sleep 5

          within "form.edit_user" do
            find("*[type=submit]").click
          end

          within_flash_messages do
            expect(page).to have_content("successfully")
          end

          find(:css, "#allow_push_notifications", visible: false).execute_script("this.checked = true")
        end
      end
    end

    context "when VAPID is disabled" do
      before do
        Rails.application.secrets[:vapid] = { enabled: false }
        driven_by(:pwa_chrome)
        switch_to_host(organization.host)
        login_as user, scope: :user
        visit decidim.notifications_settings_path
      end

      it "does not show the push notifications switch" do
        expect(page).not_to have_selector(".push-notifications")
      end
    end

    context "when VAPID keys are not set" do
      before do
        Rails.application.secrets.delete(:vapid)
        driven_by(:pwa_chrome)
        switch_to_host(organization.host)
        login_as user, scope: :user
        visit decidim.notifications_settings_path
      end

      it "does not show the push notifications switch" do
        expect(page).not_to have_selector(".push-notifications")
      end
    end
  end
end
