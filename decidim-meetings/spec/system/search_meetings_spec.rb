# frozen_string_literal: true

require "spec_helper"

describe "Search meetings" do
  include ActionView::Helpers::SanitizeHelper

  include_context "with a component"
  let(:manifest_name) { "meetings" }

  context "when meetings are published" do
    let!(:searchables) { create_list(:meeting, 3, :published, component:) }
    let!(:term) { strip_tags(searchables.first.title["en"]).split.sample }

    include_examples "searchable results"
  end

  context "when there are more meetings than the pagination" do
    let!(:meetings) { create_list(:meeting, 35, :published, component:) }

    it "views them all" do
      visit_component

      within("main") do
        expect(page).to have_content("35 meetings")
      end

      within "main nav" do
        expect(page).to have_content("Next")
      end
    end
  end

  context "when meetings are not published" do
    let!(:searchables) { create_list(:meeting, 3, component:) }
    let!(:term) { strip_tags(searchables.first.title["en"]).split.sample }
    let(:organization) { create(:organization) }

    before do
      switch_to_host(organization.host)
      visit decidim.root_path
    end

    context "when searching for indexed searchables" do
      it "does contain these searchables" do
        within "#form-search_topbar" do
          fill_in "term", with: term
          click_on
        end

        expect(page).to have_current_path decidim.search_path, ignore_query: true
        expect(page).to have_content(%(results for the search: "#{term}"))
        expect(page).to have_css(".filter-search.filter-container")
        expect(page.find("#search-count h2").text.to_i).to eq(0)
      end
    end
  end
end
