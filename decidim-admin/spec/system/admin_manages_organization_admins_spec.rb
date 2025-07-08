# frozen_string_literal: true

require "spec_helper"

describe "Organization admins" do
  let(:admin) { create(:user, :admin, :confirmed) }
  let(:organization) { admin.organization }

  before do
    switch_to_host(organization.host)
  end

  describe "Managing users" do
    before do
      login_as admin, scope: :user
      visit decidim_admin.root_path
      click_on "Participants"
      within_admin_sidebar_menu do
        click_on "Admins"
      end
    end

    it "can invite new users" do
      click_on "New admin"

      within ".new_user" do
        fill_in :user_name, with: "New admin"
        fill_in :user_email, with: "newadmin@example.org"

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_content("New admin")
      end
    end

    it "can invite a user with a specific role" do
      click_on "New admin"

      within ".new_user" do
        fill_in :user_name, with: "New user manager"
        fill_in :user_email, with: "newusermanager@example.org"
        select "Participant manager", from: :user_role

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_content("New user manager")
        expect(page).to have_content("Participant manager")
      end
    end

    context "with existing users" do
      let!(:user) do
        user = build(:user, :confirmed, :admin, organization:)
        user.invite!
        user
      end
      let!(:other_admin) { create(:user, :confirmed, :admin, organization:) }

      before do
        visit current_path
      end

      it "can resend the invitation" do
        within "tr[data-user-id=\"#{user.id}\"]" do
          find("button[data-component='dropdown']").click
          click_on "Resend invitation"
        end

        expect(page).to have_content("Invitation successfully resent")
      end

      it "can remove the admin rights" do
        expect(page).to have_content(other_admin.name)

        within "tr[data-user-id=\"#{other_admin.id}\"]" do
          find("button[data-component='dropdown']").click
          accept_confirm { click_on "Delete" }
        end

        expect(page).to have_no_content(other_admin.name)
      end

      it "cannot remove admin rights from self" do
        within "tr[data-user-id=\"#{admin.id}\"]" do
          expect(page).to have_no_css("button[data-component='dropdown']")
        end

        within "tr[data-user-id=\"#{other_admin.id}\"]" do
          find("button[data-component='dropdown']").click
          expect(page).to have_link("Delete")
        end
      end
    end
  end
end
