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

  let!(:page_component) { create(:page, component: component, body: body) }

  describe "page show" do
    before do
      visit_component
    end

    it_behaves_like "editable content for admins"

    it "renders the content of the page" do
      expect(page).to have_content("Content")
    end
  end
end
