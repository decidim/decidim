# frozen_string_literal: true

require "spec_helper"

describe "Search collaborative texts" do
  include_context "with a component"

  let(:manifest_name) { "collaborative_texts" }
  let(:component) { create(:collaborative_text_component, participatory_space:) }
  let(:search_term) { "doggo" }
  let(:search_path) { decidim.search_path(term: search_term, filter: { with_resource_type: "Decidim::CollaborativeTexts::Document" }) }
  let!(:searchables) do
    3.times.map do |i|
      create(:collaborative_text_document, :published, component:, title: "A doggo collaborative text #{i}")
    end
  end

  before do
    visit search_path
  end

  it "renders the collaborative texts section with the documents found" do
    within "#results" do
      expect(page).to have_css(".search__result h2", text: "Collaborative texts")
      expect(page).to have_css(".search__result a.card__list", count: searchables.size)
    end
  end

  it "renders the number of documents found" do
    expect(page).to have_css("#search-count h2", text: /#{searchables.size} results for the search: "#{search_term}"/)
  end

  it "renders each document title as a link to the document page" do
    searchables.each do |document|
      expect(page).to have_link(document.title, href: Decidim::ResourceLocatorPresenter.new(document).path)
    end
  end

  it "escapes the document title instead of rendering it" do
    malicious = create(:collaborative_text_document, :published, component:, title: 'A doggo <script>alert("XSS")</script> text')

    visit search_path

    expect(page).to have_css(".card__list-title", text: '<script>alert("XSS")</script>')
    expect(page).to have_no_css(".card__list-title script")
    expect(page).to have_link(translated(malicious.title), href: Decidim::ResourceLocatorPresenter.new(malicious).path)
  end
end
