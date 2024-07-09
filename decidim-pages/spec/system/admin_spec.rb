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
      create(:page, component: component, body: body)
      visit_component_admin
    end

    let!(:attributes) { attributes_for(:static_page) }

    it_behaves_like "having a rich text editor for field", ".tabs-content[data-tabs-content='page-body-tabs']", "full"

    it "updates the page", versioning: true do
      within "form.edit_page" do
        fill_in_i18n_editor(:page_body, "#page-body-tabs", **attributes[:content].except("machine_translations"))
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit_component

      expect(page).to have_content(translated(component.name).upcase)

      visit decidim_admin.root_path
      expect(page).to have_content("updated the #{translated(component.name)} page")
    end
  end

  describe "announcements" do
    before do
      create(:page, component: component, body: body)
      visit_component_admin
    end

    it_behaves_like "manage announcements"
  end
end
