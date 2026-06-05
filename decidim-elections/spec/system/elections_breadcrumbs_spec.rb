# frozen_string_literal: true

require "spec_helper"

describe "Elections Breadcrumb" do
  include_context "with a component"
  let(:manifest_name) { "elections" }

  let!(:election) { create(:election, :published, :finished, :with_internal_users_census, component:) }

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
    it "shows the correct information in breadcrumb (space, component, election)" do
      click_on translated(election.title)
      within(".menu-bar") do
        expect(page).to have_text(translated(component.participatory_space.title))
        expect(page).to have_text(translated(component.name))
        expect(page).to have_text(translated(election.title))
      end
    end
  end
end
