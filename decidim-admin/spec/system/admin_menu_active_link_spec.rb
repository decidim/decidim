# frozen_string_literal: true

require "spec_helper"

describe "Admin menu active link" do
  let(:organization) { create(:organization, available_locales: %w(en ca)) }
  let(:admin) { create(:user, :admin, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
  end

  describe "active link in the main navigation" do
    context "when navigating to a section" do
      it "marks the corresponding menu item as active" do
        visit decidim_admin.static_pages_path

        within ".layout-nav" do
          expect(page).to have_css(".is-active", text: "Pages")
        end
      end

      it "marks the Newsletters menu item as active when on the newsletters section" do
        visit decidim_admin.newsletters_path

        within ".layout-nav" do
          expect(page).to have_css(".is-active", text: "Newsletters")
        end
      end
    end

    context "when changing the locale while on a section" do
      it "keeps the active link after switching locale from Pages" do
        visit decidim_admin.static_pages_path

        within ".layout-nav" do
          expect(page).to have_css(".is-active", text: "Pages")
        end

        within_language_menu(admin: true) do
          click_on "Català"
        end

        within ".layout-nav" do
          expect(page).to have_css(".is-active", text: "Pàgines")
        end
      end

      it "keeps the active link after switching locale from Newsletters" do
        visit decidim_admin.newsletters_path

        within ".layout-nav" do
          expect(page).to have_css(".is-active", text: "Newsletters")
        end

        within_language_menu(admin: true) do
          click_on "Català"
        end

        within ".layout-nav" do
          expect(page).to have_css(".is-active", text: "Butlletins")
        end
      end
    end
  end
end
