# frozen_string_literal: true

require "spec_helper"

describe "Search participatory processes" do
  let(:organization) { create(:organization) }
  let(:term) { "doggo" }
  let(:search_path) { decidim.search_path(term:, filter: { with_resource_type: "Decidim::ParticipatoryProcess" }) }
  let!(:searchables) { 3.times.map { |i| create(:participatory_process, organization:, title: { en: "A doggo process #{i}" }) } }

  before do
    # Participatory processes are indexed on update, so publishing them is what makes them searchable
    searchables.each(&:publish!)
    switch_to_host(organization.host)
    visit search_path
  end

  it "renders the participatory processes section with the processes found" do
    within "#results" do
      expect(page).to have_css(".search__result h2", text: "Participatory processes")
      expect(page).to have_css(".search__result div.card__search", count: searchables.size)
    end
  end

  it "renders each process title as a link to the process page" do
    searchables.each do |process|
      expect(page).to have_link(translated(process.title), href: Decidim::ResourceLocatorPresenter.new(process).path)
    end
  end

  it "renders the number of processes found" do
    expect(page).to have_css("#search-count h2", text: /#{searchables.size} results for the search: "#{term}"/)
  end

  context "when the process has an active step" do
    let!(:process) { create(:participatory_process, organization:, title: { en: "A doggo process with a phase" }) }
    let!(:step) { create(:participatory_process_step, participatory_process: process, active: true, title: { en: "An active phase" }) }

    before do
      process.publish!
      visit search_path
    end

    it "renders the active step in the metadata" do
      within "div.card__search#participatory_process_#{process.id}" do
        expect(page).to have_css(".card__search-metadata", text: "An active phase")
      end
    end
  end

  context "when the process is not published" do
    let!(:unpublished) { create(:participatory_process, :unpublished, organization:, title: { en: "A doggo unpublished process" }) }

    before do
      visit search_path
    end

    it "does not render it" do
      expect(page).to have_no_link(translated(unpublished.title))
    end

    it "renders it once it is published" do
      unpublished.publish!
      visit search_path

      expect(page).to have_link(translated(unpublished.title))
    end
  end

  context "when a process title contains HTML" do
    let!(:malicious) { create(:participatory_process, organization:, title: { en: 'A doggo <script>alert("XSS")</script> process' }) }

    before do
      malicious.publish!
      visit search_path
    end

    it "escapes the title instead of rendering it" do
      expect(page).to have_css(".card__search-title", text: '<script>alert("XSS")</script>')
      expect(page).to have_no_css(".card__search-title script")
    end
  end

  context "when the results include a process group" do
    let(:group_search_path) { decidim.search_path(term:, filter: { with_resource_type: "Decidim::ParticipatoryProcessGroup" }) }
    let!(:group) { create(:participatory_process_group, organization:, title: { en: "A doggo process group" }) }
    let!(:group_process) { create(:participatory_process, organization:, participatory_process_group: group, title: { en: "A doggo process in the group" }) }

    before do
      group_process.publish!
      visit group_search_path
    end

    it "renders the process group card with its processes count" do
      within "#results" do
        expect(page).to have_css(".search__result h2", text: "Participatory process groups")
        expect(page).to have_link(
          translated(group.title),
          href: decidim_participatory_processes.participatory_process_group_path(group, locale: I18n.locale)
        )
        within "div.card__search#participatory_process_group_#{group.id}" do
          expect(page).to have_css(".card__search-metadata", text: "1 process")
        end
      end
    end
  end
end
