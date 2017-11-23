# frozen_string_literal: true

require "spec_helper"

describe "Edit a page", type: :feature do
  include_context "when managing a feature as an admin"
  let(:feature) { create(:feature, manifest_name: "pages", participatory_space: participatory_process) }
  let(:manifest_name) { "pages" }

  describe "admin page" do
    before do
      create(:page, feature: feature, body: body)
      visit_feature_admin
    end

    let(:body) do
      {
        "en" => "<p>Content</p>",
        "ca" => "<p>Contingut</p>",
        "es" => "<p>Contenido</p>"
      }
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

      visit_feature

      expect(page).to have_content("New body")
    end
  end

  describe "announcements" do
    before do
      create(:page, feature: feature, body: body)
      visit_feature_admin
    end
    it_behaves_like "manage announcements"
  end
end
