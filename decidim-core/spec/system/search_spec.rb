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
    expect(page).to have_css(".main-bar__search")
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
      expect(page).to have_css(".filter-search.filter-container")
    end

    it "has all the resources to search" do
      within ".search__filter" do
        expect(page).to have_content("All").once
        expect(page).to have_content("Participants").once
        expect(page).to have_content("Participatory processes").once
        expect(page).to have_content("Assemblies").once
        expect(page).to have_content("Conferences").once
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
      click_on(id: "dc-dialog-accept")
      click_on(id: "main-dropdown-summary-mobile")
    end

    it "shows the mobile version of the search form" do
      expect(page).to have_css("#input-search-mobile")
    end
  end

  context "when there is a malformed URL" do
    let(:participatory_space) { create(:participatory_process, :published, :with_steps, organization:) }
    let!(:proposal_component) { create(:proposal_component, participatory_space:) }
    let!(:proposals) { create_list(:proposal, 50, component: proposal_component) }

    before do
      proposals.each { |s| s.update(published_at: Time.current) }
    end

    it "displays the results page" do
      visit %{/search?filter[with_resource_type]=Decidim::Proposals::Proposal&page=2&per_page=25'"()%26%25<zzz><ScRiPt >alert("XSS")</ScRiPt>}

      expect(page).to have_content("100 results for the search")
      expect(page).to have_content("Results per page")
    end
  end
end
