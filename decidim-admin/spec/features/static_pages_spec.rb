# frozen_string_literal: true

require "spec_helper"

describe "Content pages", type: :feature do
  include ActionView::Helpers::SanitizeHelper

  let(:admin) { create :user, :admin, :confirmed }
  let(:organization) { admin.organization }

  before do
    switch_to_host(organization.host)
  end

  describe "Showing pages" do
    let!(:decidim_pages) { create_list(:static_page, 5, organization: organization) }

    before do
      visit decidim.pages_path
    end

    it "shows the list of all the pages" do
      decidim_pages.each do |decidim_page|
        expect(page).to have_css(
          "a[href=\"#{decidim.page_path(decidim_page)}\"]",
          text: decidim_page.title[I18n.locale.to_s].upcase
        )
      end
    end
  end

  describe "Managing pages" do
    before do
      login_as admin, scope: :user
      visit decidim_admin.root_path
      click_link "Pages"
    end

    it "can create new pages" do
      within ".secondary-nav" do
        find(".new").click
      end

      within ".new_static_page" do
        fill_in :static_page_slug, with: "welcome"

        fill_in_i18n(
          :static_page_title,
          "#static_page-title-tabs",
          en: "Welcome to Decidim",
          es: "Te damos la bienvendida a Decidim",
          ca: "Et donem la benvinguda a Decidim"
        )

        fill_in_i18n_editor(
          :static_page_content,
          "#static_page-content-tabs",
          en: "<p>Some HTML content</p>",
          es: "<p>Contenido HTML</p>",
          ca: "<p>Contingut HTML</p>"
        )

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_content("Welcome to Decidim")
      end
    end

    context "with existing pages" do
      let!(:decidim_page) { create(:static_page, organization: organization) }

      before do
        visit current_path
      end

      it "can edit them" do
        within find("tr", text: translated(decidim_page.title)) do
          click_link "Edit"
        end

        within ".edit_static_page" do
          fill_in_i18n(
            :static_page_title,
            "#static_page-title-tabs",
            en: "Not welcomed anymore"
          )
          fill_in_i18n_editor(
            :static_page_content,
            "#static_page-content-tabs",
            en: "This is the new <strong>content</strong>"
          )
          find("*[type=submit]").click
        end

        expect(page).to have_admin_callout("successfully")

        within "table" do
          expect(page).to have_content("Not welcomed anymore")
        end
      end

      it "can destroy them" do
        within find("tr", text: translated(decidim_page.title)) do
          accept_confirm { click_link "Destroy" }
        end

        expect(page).to have_admin_callout("successfully")

        within "table" do
          expect(page).to have_no_content(translated(decidim_page.title))
        end
      end

      it "can visit them" do
        within find("tr", text: translated(decidim_page.title)) do
          click_link "View public page"
        end

        expect(page).to have_content(translated(decidim_page.title))
        expect(page).to have_content(strip_tags(translated(decidim_page.content)))
        expect(page).to have_current_path(/#{decidim_page.slug}/)
      end
    end
  end
end
