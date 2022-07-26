# frozen_string_literal: true

require "spec_helper"

describe "Content pages", type: :system do
  include ActionView::Helpers::SanitizeHelper

  let(:admin) { create :user, :admin, :confirmed }
  let(:organization) { admin.organization }

  before do
    switch_to_host(organization.host)
  end

  describe "Showing pages" do
    let!(:decidim_pages) { create_list(:static_page, 5, :with_topic, organization:) }

    it_behaves_like "editable content for admins" do
      let(:target_path) { decidim.pages_path }
    end

    context "when requesting the pages path" do
      before do
        visit decidim.pages_path
      end

      it "shows the list of all the pages" do
        decidim_pages.each do |decidim_page|
          topic_title = decidim_page.topic.title[I18n.locale.to_s]
          page_title = decidim_page.title[I18n.locale.to_s]

          expect(page).to have_css(
            "a[href=\"#{decidim.page_path(decidim_page)}\"]",
            text: topic_title
          )
          within("details", text: topic_title) do
            find("svg", match: :first).click
            expect(page).to have_css(
              "a[href=\"#{decidim.page_path(decidim_page)}\"]",
              text: page_title
            )
          end
        end
      end
    end
  end

  describe "Managing topics" do
    context "when creating a topic" do
      before do
        login_as admin, scope: :user
        visit decidim_admin.root_path
        click_link "Pages"
      end

      it "can create topics" do
        within ".secondary-nav" do
          click_link "Create topic"
        end

        within ".new_static_page_topic" do
          fill_in_i18n(
            :static_page_topic_title,
            "#static_page_topic-title-tabs",
            en: "General",
            es: "General",
            ca: "General"
          )

          fill_in_i18n(
            :static_page_topic_description,
            "#static_page_topic-description-tabs",
            en: "<p>Some HTML content</p>",
            es: "<p>Contenido HTML</p>",
            ca: "<p>Contingut HTML</p>"
          )

          find("*[type=submit]").click
        end

        expect(page).to have_admin_callout("successfully")
        expect(page).to have_css(".card h2", text: "General")
      end
    end

    context "when editing a topic" do
      let!(:topic) { create(:static_page_topic, organization:) }

      before do
        login_as admin, scope: :user
        visit decidim_admin.root_path
        click_link "Pages"
      end

      it "can create page groups" do
        within find(".card-title", text: topic.title[I18n.locale.to_s]) do
          click_link "Edit"
        end

        within ".edit_static_page_topic" do
          fill_in_i18n(
            :static_page_topic_title,
            "#static_page_topic-title-tabs",
            en: "New title",
            es: "Nuevo título",
            ca: "Nou títol"
          )

          fill_in_i18n(
            :static_page_topic_description,
            "#static_page_topic-description-tabs",
            en: "<p>Some HTML content</p>",
            es: "<p>Contenido HTML</p>",
            ca: "<p>Contingut HTML</p>"
          )

          find("*[type=submit]").click
        end

        expect(page).to have_admin_callout("successfully")
        expect(page).to have_css(".card h2", text: "New title")
      end
    end

    context "when deleting topics" do
      let!(:topic) { create(:static_page_topic, organization:) }

      before do
        login_as admin, scope: :user
        visit decidim_admin.root_path
        click_link "Pages"
      end

      it "can delete them" do
        within find(".card", text: translated(topic.title)) do
          accept_confirm { click_link "Remove topic" }
        end

        expect(page).to have_admin_callout("successfully")

        within "table" do
          expect(page).to have_no_content(translated(topic.title))
        end
      end
    end
  end

  describe "Managing pages" do
    let!(:topic) { create(:static_page_topic, organization:) }

    before do
      login_as admin, scope: :user
      visit decidim_admin.root_path
      click_link "Pages"
    end

    it "can create new pages" do
      within ".secondary-nav" do
        click_link "Create page"
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

        select topic.title[I18n.locale.to_s], from: "Topic"
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within find(".card", text: topic.title[I18n.locale.to_s]) do
        expect(page).to have_css("tr", text: "Welcome to Decidim")
      end
    end

    context "with existing pages" do
      let!(:decidim_page) { create(:static_page, :with_topic, organization:) }
      let!(:topic) { create(:static_page_topic, organization:) }

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
          select topic.title[I18n.locale.to_s], from: "Topic"
          find("*[type=submit]").click
        end

        expect(page).to have_admin_callout("successfully")

        within find(".card", text: topic.title[I18n.locale.to_s]) do
          expect(page).to have_css("tr", text: "Not welcomed anymore")
        end
      end

      it "can delete them" do
        within find("tr", text: translated(decidim_page.title)) do
          accept_confirm { click_link "Delete" }
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
