# frozen_string_literal: true

require "spec_helper"

describe "Search meetings", type: :system do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  context "when meetings are published" do
    let!(:searchables) { create_list(:meeting, 3, :published, component: component) }
    let!(:term) { searchables.first.title["en"].split.sample }

    include_examples "searchable results"
  end

  context "when meetings are not published" do
    let!(:searchables) { create_list(:meeting, 3, component: component) }
    let!(:term) { searchables.first.title["en"].split.sample }
    let(:organization) { create(:organization) }

    before do
      switch_to_host(organization.host)
      visit decidim.root_path
    end

    context "when searching for indexed searchables" do
      it "contains these searchables" do
        fill_in "term", with: term
        find("input#term").native.send_keys :enter

        expect(page).to have_current_path decidim.search_path, ignore_query: true
        expect(page).to have_content(/results for the search: "#{term}"/i)
        expect(page).to have_selector(".filters__section")
        expect(page.find("#search-count .section-heading").text.to_i).to eq(0)
      end
    end
  end
end
