# frozen_string_literal: true

require "spec_helper"

describe "Content pages" do
  include ActionView::Helpers::SanitizeHelper

  let(:admin) { create(:user, :admin, :confirmed) }
  let(:organization) { admin.organization }

  before do
    switch_to_host(organization.host)
  end

  describe "Showing pages" do
    let!(:decidim_pages) { create_list(:static_page, 5, :with_topic, organization:) }
    let(:decidim_page) { decidim_pages.first }

    it_behaves_like "editable content for admins" do
      let(:target_path) { decidim.pages_path(locale: I18n.locale) }
    end

    context "when requesting the pages path" do
      before do
        visit decidim.pages_path(locale: I18n.locale)
      end

      it "shows the list of topics" do
        decidim_pages.each do |decidim_page|
          topic_title = decidim_page.topic.title[I18n.locale.to_s]

          expect(page).to have_content(topic_title)
        end
      end

      it "expands the topics" do
        topic_title = decidim_page.topic.title[I18n.locale.to_s]
        page_title = decidim_page.title[I18n.locale.to_s]

        within(".page__accordion", text: topic_title) do
          find("button[role=button]").click

          expect(page).to have_css(
            "a[href=\"#{decidim.page_path(decidim_page, locale: I18n.locale)}\"]",
            text: page_title
          )
        end
      end
    end
  end

  describe "Managing topics" do
    context "when creating a topic" do
      before do
        login_as admin, scope: :user
        visit decidim_admin.root_path
        click_on "Pages"
        click_on "Topics"
      end

      it "can create topics" do
        click_on "New topic"

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
        expect(page).to have_css(".table-scroll", text: "General")
      end
    end

    context "when editing a topic" do
      let!(:topic) { create(:static_page_topic, organization:) }

      before do
        login_as admin, scope: :user
        visit decidim_admin.root_path
        click_on "Pages"
        click_on "Topics"
      end

      it "can create page groups" do
        click_on translated(topic.title)

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
        expect(page).to have_css(".table-scroll", text: "New title")
      end
    end

    context "when deleting topics" do
      let!(:topic) { create(:static_page_topic, organization:) }

      before do
        login_as admin, scope: :user
        visit decidim_admin.root_path
        click_on "Pages"
        click_on "Topics"
      end

      it "can delete them" do
        within "tr", text: translated(topic.title) do
          accept_confirm { click_on "Delete" }
        end

        expect(page).to have_admin_callout("successfully")

        expect(page).to have_no_css(".table-scroll")
      end
    end
  end

  describe "Managing pages" do
    let!(:topic) { create(:static_page_topic, organization:) }
    let(:attributes) { attributes_for(:static_page) }

    before do
      login_as admin, scope: :user
      visit decidim_admin.root_path
      click_on "Pages"
    end

    context "when displaying the page form" do
      before do
        click_on "New page"
      end

      it_behaves_like "having a rich text editor", "new_static_page", "full"
    end

    it "can create new pages" do
      click_on "New page"

      within ".new_static_page" do
        fill_in :static_page_slug, with: "welcome"

        fill_in_i18n(
          :static_page_title,
          "#static_page-title-tabs",
          **attributes[:title].except("machine_translations")
        )

        fill_in_i18n_editor(
          :static_page_content,
          "#static_page-content-tabs",
          **attributes[:content].except("machine_translations")
        )

        select topic.title[I18n.locale.to_s], from: :static_page_topic_id
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within ".card", text: topic.title[I18n.locale.to_s] do
        expect(page).to have_css("tr", text: translated(attributes[:title]))
      end

      visit decidim_admin.root_path
      expect(page).to have_content("created the #{translated(attributes[:title])} static page")
    end

    context "with existing pages" do
      let!(:decidim_page) { create(:static_page, :with_topic, organization:) }
      let!(:topic) { create(:static_page_topic, organization:) }

      before do
        visit current_path
      end

      context "when displaying the page form" do
        before do
          within "tr", text: translated(decidim_page.title) do
            click_on "Edit"
          end
        end

        it_behaves_like "having a rich text editor", "edit_static_page", "full"
      end

      it "can edit them" do
        within "tr", text: translated(decidim_page.title) do
          click_on "Edit"
        end

        within ".edit_static_page" do
          fill_in_i18n(
            :static_page_title,
            "#static_page-title-tabs",
            **attributes[:title].except("machine_translations")
          )
          fill_in_i18n_editor(
            :static_page_content,
            "#static_page-content-tabs",
            **attributes[:content].except("machine_translations")
          )
          select topic.title[I18n.locale.to_s], from: :static_page_topic_id
          find("*[type=submit]").click
        end

        expect(page).to have_admin_callout("successfully")

        within ".card", text: topic.title[I18n.locale.to_s] do
          expect(page).to have_css("tr", text: translated(attributes[:title]))
        end

        visit decidim_admin.root_path
        expect(page).to have_content("updated the #{translated(attributes[:title])} static page")
      end

      it "can delete them" do
        within "tr", text: translated(decidim_page.title) do
          accept_confirm { click_on "Delete" }
        end

        expect(page).to have_admin_callout("successfully")

        within "table" do
          expect(page).to have_no_content(translated(decidim_page.title))
        end
      end

      it "can visit them" do
        new_window = window_opened_by do
          within "tr", text: translated(decidim_page.title) do
            click_on "View public page"
          end
        end

        page.within_window(new_window) do
          expect(page).to have_content(translated(decidim_page.title))
          expect(page).to have_content(strip_tags(translated(decidim_page.content)))
          expect(page).to have_current_path(/#{decidim_page.slug}/)
        end
      end
    end
  end
end
