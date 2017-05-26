# frozen_string_literal: true

require "spec_helper"

describe "Organization admins", type: :feature do
  include ActionView::Helpers::SanitizeHelper

  let(:admin) { create :user, :admin, :confirmed }
  let(:organization) { admin.organization }

  before do
    switch_to_host(organization.host)
  end

  describe "Managing users" do
    before do
      login_as admin, scope: :user
      visit decidim_admin.root_path
      click_link "Users"
      click_link "Admins"
    end

    it "can invite new users" do
      within ".card-title" do
        find(".button--title").click
      end

      within ".new_user" do
        fill_in :user_name, with: "New admin"
        fill_in :user_email, with: "newadmin@example.org"

        find("*[type=submit]").click
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).to have_content("New admin")
      end
    end

    context "with existing users" do
      let!(:user) do
        user = build(:user, :confirmed, :admin, organization: organization)
        user.invite!
        user
      end
      let!(:other_admin) { create(:user, :confirmed, :admin, organization: organization) }

      before do
        visit current_path
      end

      it "can resend the invitation" do
        within "tr[data-user-id=\"#{user.id}\"]" do
          page.find(".action-icon.resend-invitation").click
        end

        expect(page).to have_content("Invitation email sent successfully")
      end

      it "can remove the admin rights" do
        expect(page).to have_content(other_admin.name)

        within "tr[data-user-id=\"#{other_admin.id}\"]" do
          page.find(".action-icon.action-icon--remove").click
        end

        expect(page).not_to have_content(other_admin.name)
      end
    end
  end
end
