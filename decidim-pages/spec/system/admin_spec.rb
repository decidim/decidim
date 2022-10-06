# frozen_string_literal: true

require "spec_helper"

describe "Edit a page", type: :system do
  include_context "when managing a component as an admin"
  let(:component) { create(:component, manifest_name: "pages", participatory_space: participatory_process) }
  let(:manifest_name) { "pages" }

  let(:body) do
    {
      "en" => "<p>Content</p>",
      "ca" => "<p>Contingut</p>",
      "es" => "<p>Contenido</p>"
    }
  end

  describe "admin page" do
    before do
      create(:page, component:, body:)
      visit_component_admin
    end

    it "updates the page" do
      new_body = {
        en: "<p>New body</p>",
        ca: "<p>Nou cos</p>",
        es: "<p>Nuevo cuerpo</p>"
      }

      within "form.edit_page" do
        fill_in_i18n_editor(:page_body, "#page-body-tabs", new_body)
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit_component

      expect(page).to have_content("New body")
    end
  end

  describe "announcements" do
    before do
      create(:page, component:, body:)
      visit_component_admin
    end

    it_behaves_like "manage announcements"
  end
end
