# frozen_string_literal: true

require "spec_helper"

describe "Blogs breadcrumbs" do
  include_context "with a component"
  let(:manifest_name) { "blogs" }
  let(:author) { organization }
  let(:body) { { en: "Short description", ca: "Descripció curta", es: "Descripción corta" } }
  let!(:post) { create(:post, component:, author:, body:) }

  before do
    visit_component
  end

  describe "index" do
    it "shows the correct information in breadcrumb" do
      within(".menu-bar") do
        expect(page).to have_content(translated(component.participatory_space.title))
        expect(page).to have_content(translated(component.name))
      end
    end
  end

  describe "show" do
    it "shows the correct information in breadcrumb" do
      click_on translated(post.title)

      within(".menu-bar") do
        expect(page).to have_content(translated(component.participatory_space.title))
        expect(page).to have_content(translated(component.name))
        expect(page).to have_content(translated(post.title))
      end
    end
  end
end
