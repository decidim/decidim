# coding: utf-8
# frozen_string_literal: true
require "spec_helper"

describe "Edit a page", type: :feature do
  include_context "feature admin"
  let(:manifest_name) { "pages" }

  describe "admin page" do
    before do
      create(:page, feature: feature, title: title, body: body)
      visit_feature_admin
    end

    let(:title) do
      {
        "en" => "Hello world",
        "ca" => "Hola món",
        "es" => "Hola mundo"
      }
    end

    let(:body) do
      {
        "en" => "<p>Content</p>",
        "ca" => "<p>Contingut</p>",
        "es" => "<p>Contenido</p>"
      }
    end

    it "updates the page" do
      new_title = {
        en: "New title",
        ca: "Nou títol",
        es: "Nuevo título"
      }

      new_body = {
        en: "<p>New body</p>",
        ca: "<p>Nou cos</p>",
        es: "<p>Nuevo cuerpo</p>"
      }

      within "form.edit_page" do
        fill_in_i18n(:page_title, "#title-tabs", new_title)
        fill_in_i18n_editor(:page_body, "#body-tabs", new_body)
        find("*[type=submit]").click
      end

      within_flash_messages do
        expect(page).to have_content("successfully")
      end

      visit_feature

      expect(page).to have_title("New title")
      expect(page).to have_content("New body")
    end
  end
end
