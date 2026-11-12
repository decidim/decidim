# frozen_string_literal: true

require "spec_helper"

describe "Search accountability results" do
  include_context "with a component"

  let(:manifest_name) { "accountability" }
  let(:component) { create(:accountability_component, participatory_space:) }
  let(:taxonomies) do
    create_list(:taxonomy, 2, :with_parent, organization: component.organization,
                                            name: { "ca" => "Taxonomy3", "en" => "Taxonomy3" })
  end
  let(:term) { "doggo" }
  let!(:searchables) { 3.times.map { |i| create(:result, taxonomies:, component:, title: { en: "A doggo result #{i}" }) } }

  before do
    visit decidim.search_path(term:, filter: { with_resource_type: "Decidim::Accountability::Result" })
  end

  it "renders the results section with the results found" do
    within "#results" do
      expect(page).to have_css(".search__result h2", text: "Results")
      expect(page).to have_css(".search__result .card__list", count: searchables.size)
    end
  end

  it "renders each result title as a link to the result page" do
    searchables.each do |result|
      expect(page).to have_link(translated(result.title), href: Decidim::ResourceLocatorPresenter.new(result).path)
    end
  end

  it "renders the progress of each result" do
    searchables.each do |result|
      within ".card__list", text: translated(result.title) do
        expect(page).to have_css(".accountability__progress", text: "#{result.progress.to_i}%")
      end
    end
  end

  context "when a result title contains HTML" do
    let!(:malicious) { create(:result, component:, title: { en: 'A doggo <script>alert("XSS")</script> result' }) }

    before do
      visit decidim.search_path(term:, filter: { with_resource_type: "Decidim::Accountability::Result" })
    end

    it "escapes the title instead of rendering it" do
      expect(page).to have_css(".card__list-title", text: '<script>alert("XSS")</script>')
      expect(page).to have_no_css(".card__list-title script")
    end
  end
end
