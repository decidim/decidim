# frozen_string_literal: true

require "spec_helper"

describe "Search" do
  let(:organization) { create(:organization) }
  let(:term) { "dolorem" }

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  it "has a topbar search form" do
    expect(page).to have_selector(".main-bar__search")
  end

  context "when searching from the top bar" do
    before do
      within ".main-bar__search" do
        fill_in "term", with: term
        find("input#input-search").native.send_keys :enter
      end
    end

    it "is not indexable by crawlers" do
      expect(page.find('meta[name="robots"]', visible: false)[:content]).to eq("noindex")
    end

    it "displays the results page" do
      expect(page).to have_current_path decidim.search_path, ignore_query: true
      expect(page).to have_content(/results for the search: "#{term}"/i)
      expect(page).to have_selector(".filter-search.filter-container")
    end

    it "has all the resources to search" do
      within ".search__filter" do
        expect(page).to have_content("All").once
        expect(page).to have_content("Participants").once
        expect(page).to have_content("Groups").once
        expect(page).to have_content("Participatory processes").once
        expect(page).to have_content("Assemblies").once
        expect(page).to have_content("Conferences").once
        expect(page).to have_content("Votings").once
        expect(page).to have_content("Initiatives").once
        expect(page).to have_content("Meetings").once
        expect(page).to have_content("Proposals").once
        expect(page).to have_content("Budgets").once
        expect(page).to have_content("Projects").once
        expect(page).to have_content("Debates").once
        expect(page).to have_content("Posts").once
        expect(page).to have_content("Comments").once
      end
    end
  end

  context "when the device is a mobile" do
    before do
      driven_by(:iphone)
      switch_to_host(organization.host)
      visit decidim.root_path

      click_button(id: "dc-dialog-accept")
      click_button(id: "dropdown-trigger-links-mobile-search")
    end

    it "shows the mobile version of the search form" do
      expect(page).to have_css("#input-search-mobile")
    end
  end
end
