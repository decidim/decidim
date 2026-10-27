# frozen_string_literal: true

require "spec_helper"

describe "Search initiatives" do
  include ActionView::Helpers::TranslationHelper
  include Decidim::DateRangeHelper

  let(:organization) { create(:organization) }
  let(:term) { "doggo" }
  let(:search_path) { decidim.search_path(term:, filter: { with_resource_type: "Decidim::Initiative" }) }
  # Initiatives are indexed on update, so they only become searchable once published
  let!(:searchables) do
    3.times.map { |i| create(:initiative, organization:, published_at: nil, title: { en: "A doggo initiative #{i}" }) }
  end

  before do
    searchables.each(&:publish!)
    switch_to_host(organization.host)
    visit search_path
  end

  it "renders the initiatives section with the initiatives found" do
    within "#results" do
      expect(page).to have_css(".search__result h2", text: "Initiatives")
      expect(page).to have_css(".search__result div.card__search", count: searchables.size)
    end
  end

  it "renders each initiative title as a link to the initiative page" do
    searchables.each do |initiative|
      expect(page).to have_link(translated(initiative.title), href: Decidim::ResourceLocatorPresenter.new(initiative).path)
    end
  end

  it "renders the number of initiatives found" do
    expect(page).to have_css("#search-count h2", text: /#{searchables.size} results for the search: "#{term}"/)
  end

  it "renders the state badge and the signature dates for each initiative" do
    searchables.each do |initiative|
      within "div.card__search#initiative_#{initiative.id}" do
        expect(page).to have_css(".card__search-metadata .initiative-status", text: "Open")
        expect(page).to have_css(
          ".card__search-metadata",
          text: format_date_range(initiative.signature_start_date.to_time, initiative.signature_end_date.to_time)
        )
      end
    end
  end

  context "when the initiative is not published" do
    let!(:unpublished) { create(:initiative, organization:, published_at: nil, title: { en: "A doggo unpublished initiative" }) }

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

  context "when an initiative title contains HTML" do
    let!(:malicious) { create(:initiative, organization:, published_at: nil, title: { en: 'A doggo <script>alert("XSS")</script> initiative' }) }

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
