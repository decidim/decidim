# frozen_string_literal: true

require "spec_helper"

describe "Search", type: :system do
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

    it "displays the results page" do
      expect(page).to have_current_path decidim.search_path, ignore_query: true
      expect(page).to have_content(/results for the search: "#{term}"/i)
      expect(page).to have_selector(".filter-search.filter-container")
    end
  end

  context "when the device is a mobile" do
    before do
      driven_by(:iphone)
      switch_to_host(organization.host)
      visit decidim.root_path

      click_button(id: "dc-dialog-accept")
      within ".main-bar__links-mobile" do
        find("a[href*='search']").click
      end
    end

    it "shows the mobile version of the search form" do
      expect(page).to have_css("#input-search")
    end
  end
end
