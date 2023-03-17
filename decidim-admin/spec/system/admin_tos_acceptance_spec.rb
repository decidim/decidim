# frozen_string_literal: true

require "spec_helper"

describe "AdminTosAcceptance", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, admin_terms_accepted_at: nil, organization:) }
  let(:review_message) { "Please take a moment to review Admin Terms of Use. Otherwise you won't be able to manage the platform" }

  before do
    switch_to_host(organization.host)
  end

  describe "when an admin" do
    before do
      login_as user, scope: :user
    end

    context "when they visit the dashbaord" do
      before do
        visit decidim_admin.root_path
      end

      it "has a message that they need to accept the admin TOS" do
        expect(page).to have_content(review_message)
      end

      it "has only the Dashboard menu item in the main navigation" do
        within ".main-nav" do
          expect(page).to have_content("Dashboard")
          expect(page).to have_selector("li a", count: 1)
        end
      end
    end

    context "when they visit other admin pages" do
      before do
        visit decidim_admin.newsletters_path
      end

      it "has a message that they need to accept the admin TOS" do
        expect(page).to have_content(review_message)
      end
    end

    context "when they visit other admin pages from other engines" do
      before do
        visit decidim_admin_participatory_processes.participatory_processes_path
      end

      it "has a message that they need to accept the admin TOS" do
        expect(page).to have_content(review_message)
      end

      it "allows accepting and redirects to the previous page" do
        click_button "I agree with the terms"
        expect(page).to have_content("New process")
        expect(page).to have_content("Process types")
        expect(page).to have_content("Process groups")
      end
    end

    context "when they visit the TOS page" do
      before do
        visit decidim_admin.admin_terms_show_path
      end

      it "renders the TOS page" do
        expect(page).to have_content("Agree to the terms of use")
      end

      it "allows accepting the terms" do
        click_button "I agree with the terms"
        expect(page).to have_content("Activity")
        expect(page).to have_content("Metrics")

        within ".main-nav" do
          expect(page).to have_content("Dashboard")
          expect(page).to have_content("Newsletters")
          expect(page).to have_content("Participants")
          expect(page).to have_content("Settings")
          expect(page).to have_content("Admin activity log")
        end
      end
    end
  end
end
