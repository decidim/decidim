# coding: utf-8
# frozen_string_literal: true
require "spec_helper"

describe "Show a page", type: :feature do
  include_context "component"

  let(:feature_manifest) { Decidim.find_feature_manifest("pages") }
  let(:component_manifest) { Decidim.find_component_manifest("page") }

  describe "page show" do
    before do
      create(:page, component: component, title: title, body: body)
      visit_component
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

    it "renders the content of the page" do
      expect(page).to have_title("Hello world")
      expect(page).to have_content("Content")
    end
  end
end
