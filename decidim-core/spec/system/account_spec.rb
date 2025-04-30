# frozen_string_literal: true

require "spec_helper"

describe "Account" do
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
        find_by_id("user_avatar_button").click

        within ".upload-modal" do
          click_on "Remove"
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
          all("*[type=submit]").last.click
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

    describe "when updating the user's nickname" do
      it "changes the user's nickname - 'nickname'" do
        within "form.edit_user" do
          fill_in "Nickname", with: "nickname"
          find("*[type=submit]").click
        end

        expect(page).to have_content("Your account was successfully updated.")
        expect(page).to have_field("user[nickname]", with: "nickname", type: "text")
      end

      it "respects the maxlength attribute with a really long word - 'nicknamenicknamenickname'" do
        within "form.edit_user" do
          fill_in "Nickname", with: "nicknamenicknamenickname"
          find("*[type=submit]").click
        end

        expect(page).to have_content("Your account was successfully updated.")
        expect(page).to have_field("user[nickname]", with: "nicknamenicknamenick", type: "text")
      end

      it "shows error when word has a capital letter - 'nickName'" do
        within "form.edit_user" do
          fill_in "Nickname", with: "nickName"
          find("*[type=submit]").click
        end

        expect(page).to have_content("There was a problem updating your account.")
        expect(page).to have_content("The nickname must be lowercase and contain no spaces")
        expect(page).to have_field("user[nickname]", with: "nickName", type: "text")
      end

      it "shows error when word starts with a capital letter - 'Nickname'" do
        within "form.edit_user" do
          fill_in "Nickname", with: "Nickname"
          find("*[type=submit]").click
        end

        expect(page).to have_content("There was a problem updating your account.")
        expect(page).to have_field("user[nickname]", with: "Nickname", type: "text")
      end

      it "shows error when string has a space - 'nick name'" do
        within "form.edit_user" do
          fill_in "Nickname", with: "nick name"
          find("*[type=submit]").click
        end

        expect(page).to have_content("There was a problem updating your account.")
        expect(page).to have_field("user[nickname]", with: "nick name", type: "text")
      end
    end

    describe "when update password" do
      let!(:encrypted_password) { user.encrypted_password }
      let(:new_password) { "decidim1234567890" }

      before do
        click_on "Change password"
      end

      it "toggles old and new password fields" do
        within "form.edit_user" do
          expect(page).to have_content("must not be too common (e.g. 123456) and must be different from your nickname and your email.")
          expect(page).to have_field("user[password]", with: "", type: "password")
          expect(page).to have_field("user[old_password]", with: "", type: "password")
          click_on "Change password"
          expect(page).to have_no_field("user[password]", with: "", type: "password")
          expect(page).to have_no_field("user[old_password]", with: "", type: "password")
        end
      end

      it "shows fields if password is wrong" do
        within "form.edit_user" do
          fill_in "Password", with: new_password
          fill_in "Current password", with: "wrong password12345"
          find("*[type=submit]").click
        end
        expect(page).to have_field("user[password]", with: "decidim1234567890", type: "password")
        expect(page).to have_content("is invalid")
      end

      it "changes the password with correct password" do
        within "form.edit_user" do
          fill_in "Password", with: new_password
          fill_in "Current password", with: password
          find("*[type=submit]").click
        end
        within_flash_messages do
          expect(page).to have_content("successfully")
        end
        expect(user.reload.encrypted_password).not_to eq(encrypted_password)
        expect(page).to have_no_field("user[password]", with: "", type: "password")
        expect(page).to have_no_field("user[old_password]", with: "", type: "password")
      end
    end

    context "when update email" do
      let(:pending_email) { "foo@bar.com" }

      context "when typing new email" do
        before do
          within "form.edit_user" do
            fill_in "Your email", with: pending_email
            find("*[type=submit]").click
          end
        end

        it "toggles the current password" do
          expect(page).to have_content("In order to confirm the changes to your account, please provide your current password.")
          expect(find_by_id("user_old_password")).to be_visible
          expect(page).to have_content "Current password"
          expect(page).to have_no_content "Password"
        end

        it "renders the old password with error" do
          within "form.edit_user" do
            find("*[type=submit]").click
            fill_in :user_old_password, with: "wrong password"
            find("*[type=submit]").click
          end
          within ".flash.alert" do
            expect(page).to have_content "There was a problem updating your account."
          end
          within ".old-user-password" do
            expect(page).to have_content "is invalid"
          end
        end
      end

      context "when correct old password" do
        before do
          within "form.edit_user" do
            fill_in "Your email", with: pending_email
            find("*[type=submit]").click
            fill_in :user_old_password, with: password

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
          expect(page).to have_css("#user_email[disabled='disabled']")
          expect(page).to have_content("We have sent an email to #{pending_email} to verify your new email address")
        end

        it "resend confirmation" do
          within "#email-change-pending" do
            click_on "Send again"
          end
          expect(page).to have_content("Confirmation email resent successfully to #{pending_email}")
          perform_enqueued_jobs
          perform_enqueued_jobs

          # the emails also include the update email notification
          expect(emails.count).to eq(3)
          visit last_email_link
          expect(page).to have_content("Your email address has been successfully confirmed")
        end

        it "cancels the email change" do
          expect(Decidim::User.find(user.id).unconfirmed_email).to eq(pending_email)
          within "#email-change-pending" do
            click_on "cancel"
          end

          expect(page).to have_content("Email change cancelled successfully")
          expect(page).to have_no_content("Email change verification")
          expect(Decidim::User.find(user.id).unconfirmed_email).to be_nil
        end
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
          page.find("[for='email_on_assigned_proposals']").click
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

    context "when on the delete my account page" do
      before do
        visit decidim.delete_account_path
      end

      it "does not display the authorizations message by default" do
        expect(page).to have_no_content("Some data bound to your authorization will be saved for security.")
      end

      it "the user can delete their account" do
        within ".delete-account" do
          fill_in :delete_user_delete_account_delete_reason, with: "I just want to delete my account"
          click_on "Delete my account"
        end

        click_on "Yes, I want to delete my account"

        within_flash_messages do
          expect(page).to have_content("successfully")
        end

        click_on("Log in", match: :first)

        within ".new_user" do
          fill_in :session_user_email, with: user.email
          fill_in :session_user_password, with: password
          find("*[type=submit]").click
        end

        expect(page).to have_no_content("Signed in successfully")
        expect(page).to have_no_content(user.name)
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
        allow(Decidim).to receive(:vapid_public_key).and_return(vapid_keys[:public_key])
        allow(Decidim).to receive(:vapid_private_key).and_return(vapid_keys[:private_key])

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

          find_by_id("allow_push_notifications", visible: false).execute_script("this.checked = true")
        end
      end
    end

    context "when VAPID is disabled" do
      before do
        allow(Decidim).to receive(:vapid_public_key).and_return("")
        driven_by(:pwa_chrome)
        switch_to_host(organization.host)
        login_as user, scope: :user
        visit decidim.notifications_settings_path
      end

      it "does not show the push notifications switch" do
        expect(page).to have_no_selector(".push-notifications")
      end
    end

    context "when VAPID keys are not set" do
      before do
        allow(Decidim).to receive(:vapid_public_key).and_return(nil)
        driven_by(:pwa_chrome)
        switch_to_host(organization.host)
        login_as user, scope: :user
        visit decidim.notifications_settings_path
      end

      it "does not show the push notifications switch" do
        expect(page).to have_no_selector(".push-notifications")
      end
    end
  end
end
