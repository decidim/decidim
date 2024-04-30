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
      expect(page).to have_content(/results for the search: "#{term}"/i)
      expect(page).to have_selector(".filters__section")
    end
  end

  context "when the device is a mobile" do
    before do
      driven_by(:iphone)
      switch_to_host(organization.host)
      visit decidim.root_path

      within ".topbar .topbar__menu" do
        page.find("button").click
      end
    end

    it "shows the mobile version of the search form" do
      within ".off-canvas .search-off-canvas-holder" do
        expect(page).to have_css("#form-search_topbar")
      end
    end
  end

  context "when there is a malformed URL" do
    let(:participatory_space) { create(:participatory_process, :published, :with_steps, organization: organization) }
    let!(:proposal_component) { create(:proposal_component, participatory_space: participatory_space) }
    let!(:proposals) { create_list(:proposal, 11, component: proposal_component) }

    before do
      proposals.each { |s| s.update(published_at: Time.current) }
    end

    it "displays the results page" do
      visit %{/search?filter[with_resource_type]=Decidim::Proposals::Proposal&page=2&per_page=10'"()%26%25<zzz><ScRiPt >alert("XSS")</ScRiPt>}

      expect(page).to have_content("22 RESULTS FOR THE SEARCH")
    end
  end
end
