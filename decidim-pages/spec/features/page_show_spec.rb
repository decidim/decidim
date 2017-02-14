# coding: utf-8
# frozen_string_literal: true
require "spec_helper"

describe "Show a page", type: :feature do
  include_context "feature"
  let(:manifest_name) { "pages" }

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

  let!(:page_feature) { create(:page, feature: feature, title: title, body: body) }

  describe "page show" do
    before do
      visit_feature
    end

    it "renders the content of the page" do
      expect(page).to have_title("Hello world")
      expect(page).to have_content("Content")
    end
  end
end
