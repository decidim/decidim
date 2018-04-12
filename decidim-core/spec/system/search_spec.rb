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
    expect(page).to have_selector(".topbar__search")
  end

  context "when searching from the top bar" do
    before do
      within ".topbar__search" do
        fill_in "term", with: term
        find("input#term").native.send_keys :enter
      end
    end

    it "displays the results page" do
      expect(page).to have_current_path decidim.search_path, ignore_query: true
      expect(page).to have_no_content("results for the search: #{term}")
      expect(page).to have_selector(".filters__section")
    end
  end
end
