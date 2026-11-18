# frozen_string_literal: true

require "spec_helper"

describe "Search conferences" do
  include ActionView::Helpers::TranslationHelper
  include Decidim::DateRangeHelper

  let(:organization) { create(:organization) }
  let(:term) { "doggo" }
  let(:search_path) { decidim.search_path(term:, filter: { with_resource_type: "Decidim::Conference" }) }
  let!(:searchables) { 3.times.map { |i| create(:conference, organization:, title: { en: "A doggo conference #{i}" }) } }

  before do
    # Conferences are indexed on update, so publishing them is what makes them searchable
    searchables.each(&:publish!)
    switch_to_host(organization.host)
    visit search_path
  end

  it "renders the conferences section with the conferences found" do
    within "#results" do
      expect(page).to have_css(".search__result h2", text: "Conferences")
      expect(page).to have_css(".search__result div.card__search", count: searchables.size)
    end
  end

  it "renders each conference title as a link to the conference page" do
    searchables.each do |conference|
      expect(page).to have_link(translated(conference.title), href: Decidim::ResourceLocatorPresenter.new(conference).path)
    end
  end

  it "renders the number of conferences found" do
    expect(page).to have_css("#search-count h2", text: /#{searchables.size} results for the search: "#{term}"/)
  end

  it "renders the dates metadata for each conference" do
    searchables.each do |conference|
      within "div.card__search#conference_#{conference.id}" do
        expect(page).to have_css(
          ".card__search-metadata",
          text: format_date_range(conference.start_date.to_time, conference.end_date.to_time)
        )
      end
    end
  end

  context "when the conference is not published" do
    let!(:unpublished) { create(:conference, :unpublished, organization:, title: { en: "A doggo unpublished conference" }) }

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

  context "when a conference title contains HTML" do
    let!(:malicious) { create(:conference, organization:, title: { en: 'A doggo <script>alert("XSS")</script> conference' }) }

    before do
      malicious.publish!
      visit search_path
    end

    it "escapes the title instead of rendering it" do
      expect(page).to have_css(".card__search-title", text: '<script>alert("XSS")</script>')
      expect(page).to have_no_css(".card__search-title script")
    end
  end
end
