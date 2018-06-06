# frozen_string_literal: true

require "spec_helper"

describe "Invite friends", type: :system do
  let(:user) { create(:user, :confirmed) }
  let(:organization) { user.organization }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  describe "navigation" do
    it "shows the account form when clicking on the menu" do
      visit decidim.root_path

      within_user_menu do
        find("a", text: "Invite friends").click
      end

      expect(page).to have_css("form.new_invitations")
    end
  end

  context "when on the invitations page" do
    before do
      visit decidim.account_invitations_path
    end

    describe "when no email is entered" do
      it "shows an error" do
        within "form.new_invitations" do
          find("*[type=submit]").click
        end

        within_flash_messages do
          expect(page).to have_content("Please enter some email addresses")
        end
      end
    end

    describe "correctly entering emails" do
      it "invites those emails" do
        clear_emails

        within "form.new_invitations" do
          fill_in :invitations_email_1, with: "superduper@example.org"
          fill_in :invitations_email_2, with: "batman@example.org"
          fill_in :invitations_email_3, with: "robin@example.org"
          fill_in :invitations_email_4, with: "ironman@example.org"
          fill_in :invitations_email_5, with: "spiderman@example.org"
          fill_in :invitations_email_6, with: "antman@example.org"

          find("u", text: "Customize the invitation message").click
          fill_in :invitations_custom_text, with: "Check this out, looks awesome!"

          perform_enqueued_jobs { find("*[type=submit]").click }
        end

        within_flash_messages do
          expect(page).to have_content("We've sent the invites to your friends!")
        end

        expect(emails.count).to eq 6
        first_email = emails.find{ |email| email.to.include?("superduper@example.org") }
        expect(email_body(first_email)).to match /Hello superduper/
        expect(email_body(first_email)).to match /Check this out, looks awesome!/
      end
    end
  end
end
