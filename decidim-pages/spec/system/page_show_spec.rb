# frozen_string_literal: true

require "spec_helper"

describe "Show a page", type: :system do
  include_context "with a component"
  let(:manifest_name) { "pages" }

  let(:body) do
    {
      "en" => "<p>Content</p>",
      "ca" => "<p>Contingut</p>",
      "es" => "<p>Contenido</p>"
    }
  end

  let!(:page_component) { create(:page, component:, body:) }

  describe "page show" do
    it_behaves_like "editable content for admins" do
      let(:target_path) { main_component_path(component) }
    end

    context "when requesting the page path" do
      before do
        visit_component
      end

      it_behaves_like "accessible page"

      it "renders the content of the page" do
        expect(page).to have_content("Content")
      end
    end
  end
end
