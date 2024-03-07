# frozen_string_literal: true

require "spec_helper"

describe "Show a page" do
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
      it_behaves_like "has embedded video in description", :body

      it "renders the content of the page" do
        expect(page).to have_content("Content")
      end
    end

    context "when there is no content in the page" do
      let(:body) { nil }

      before do
        visit_component
      end

      it "shows an empty page with a message" do
        within "main" do
          expect(page).to have_content("There are no contents in this page yet.")
        end
      end
    end

    context "when the content is an empty paragraph" do
      let(:body) do
        {
          "en" => "<p></p>",
          "ca" => "<p></p>",
          "es" => "<p></p>"
        }
      end

      before do
        visit_component
      end

      it "shows an empty page with a message" do
        within "main" do
          expect(page).to have_content("There are no contents in this page yet.")
        end
      end
    end

    context "when there is no content in the current locale" do
      let(:body) do
        {
          "en" => "<p>Content</p>",
          "ca" => "<p></p>",
          "es" => "<p></p>"
        }
      end

      it "shows the default locale content" do
        I18n.with_locale :ca do
          visit_component

          within "main" do
            expect(page).to have_content("Content")
          end
        end
      end
    end
  end
end
