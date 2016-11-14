# frozen_string_literal: true
require "spec_helper"

describe "Content pages", type: :feature do
  include ActionView::Helpers::SanitizeHelper

  let(:admin) { create :user, :admin, :confirmed }
  let(:organization) { admin.organization }

  before do
    switch_to_host(organization.host)
  end

  describe "Managing pages" do
    before do
      login_as admin, scope: :user
      visit decidim_admin.root_path
      click_link "Pages"
    end

    it "can create new pages" do
      find(".actions .new").click

      within ".new_static_page" do
        fill_in :static_page_slug, with: "welcome"

        fill_in_i18n(
          :static_page_title,
          "#title-tabs",
          en: "Welcome to Decidim",
          es: "Te damos la bienvendida a Decidim",
          ca: "Et donem la benvinguda a Decidim"
        )

        fill_in_i18n(
          :static_page_content,
          "#content-tabs",
          en: "<p>Some HTML content</p>",
          es: "<p>Contenido HTML</p>",
          ca: "<p>Contingut HTML</p>"
        )

        find("*[type=submit]").click
      end

      within ".flash" do
        expect(page).to have_content("successfully")
      end

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
            "#title-tabs",
            en: "Not welcomed anymore",
          )
          fill_in_i18n(
            :static_page_content,
            "#content-tabs",
            en: "This is the new <strong>content</strong>",
          )
          find("*[type=submit]").click
        end

        within ".flash" do
          expect(page).to have_content("successfully")
        end

        within "table" do
          expect(page).to have_content("Not welcomed anymore")
          click_link("Not welcomed anymore")
        end

        within "dl" do
          expect(page).to have_content("This is the new content")
        end
      end

      it "can destroy them" do
        within find("tr", text: translated(decidim_page.title)) do
          click_link "Destroy"
        end

        within ".flash" do
          expect(page).to have_content("successfully")
        end

        within "table" do
          expect(page).to_not have_content(translated(decidim_page.title))
        end
      end

      it "can visit them" do
        within find("tr", text: translated(decidim_page.title)) do
          click_link "View public page"
        end

        expect(page).to have_content(translated(decidim_page.title))
        expect(page).to have_content(strip_tags(translated(decidim_page.content)))
        expect(current_path).to include(decidim_page.slug)
      end
    end
  end
end
