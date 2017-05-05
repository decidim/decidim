# frozen_string_literal: true
require "spec_helper"

describe "Organization scopes", type: :feature do
  include ActionView::Helpers::SanitizeHelper

  let(:admin) { create :user, :admin, :confirmed }
  let(:organization) { admin.organization }

  before do
    switch_to_host(organization.host)
  end

  describe "Managing scopes" do
    before do
      login_as admin, scope: :user
      visit decidim_admin.root_path
      click_link "Settings"
      click_link "Scopes"
    end

    it "can create new scopes" do
      click_link "Add"

      within ".new_scope" do
        fill_in :scope_name, with: "My nice district"

        find("*[type=submit]").click
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).to have_content("My nice district")
      end
    end

    context "with existing scopes" do
      let!(:scope) { create(:scope, organization: organization) }

      before do
        visit current_path
      end

      it "can edit them" do
        within find("tr", text: scope.name) do
          page.find("a.action-icon.action-icon--edit").click
        end

        within ".edit_scope" do
          fill_in :scope_name, with: "Another district"
          find("*[type=submit]").click
        end

        within ".callout-wrapper" do
          expect(page).to have_content("successfully")
        end

        within "table" do
          expect(page).to have_content("Another district")
        end
      end

      it "can destroy them" do
        within find("tr", text: scope.name) do
          page.find("a.action-icon.action-icon--remove").click
        end

        within ".callout-wrapper" do
          expect(page).to have_content("successfully")
        end

        within "table" do
          expect(page).not_to have_content(scope.name)
        end
      end
    end
  end
end
