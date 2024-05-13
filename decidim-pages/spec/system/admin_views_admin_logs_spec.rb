# frozen_string_literal: true

require "spec_helper"

describe "Admin views admin logs" do
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

  describe "Page" do
    let!(:attributes) { attributes_for(:static_page) }

    before do
      create(:page, component:, body:)
      visit_component_admin
    end

    it "updates the page", versioning: true do
      within "form.edit_page" do
        fill_in_i18n_editor(:page_body, "#page-body-tabs", **attributes[:content].except("machine_translations"))
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end
  end
end
