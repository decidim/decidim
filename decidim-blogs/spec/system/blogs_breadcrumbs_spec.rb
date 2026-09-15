# frozen_string_literal: true

require "spec_helper"

describe "Blogs Breadcrumb" do
  include_context "with a component"
  let(:manifest_name) { "blogs" }
  let!(:post) { create(:post, component:) }

  before do
    visit_component
  end

  describe "index" do
    it "shows the correct information in breadcrumb (space, component)" do
      within(".menu-bar") do
        expect(page).to have_text(translated(component.participatory_space.title))
        expect(page).to have_text(translated(component.name))
      end
    end
  end

  describe "show" do
    it "shows the correct information in breadcrumb (space, component, post)" do
      click_on translated(post.title)

      within(".menu-bar") do
        expect(page).to have_text(translated(component.participatory_space.title))
        expect(page).to have_text(translated(component.name))
        expect(page).to have_text(translated(post.title))
      end
    end
  end
end
