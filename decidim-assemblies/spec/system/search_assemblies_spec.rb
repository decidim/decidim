# frozen_string_literal: true

require "spec_helper"

describe "Search assemblies" do
  let(:organization) { create(:organization) }
  let(:term) { "doggo" }
  let(:search_path) { decidim.search_path(term:, filter: { with_resource_type: "Decidim::Assembly" }) }
  let!(:searchables) { 3.times.map { |i| create(:assembly, organization:, title: { en: "A doggo assembly #{i}" }) } }

  before do
    # Assemblies are indexed on update, so publishing them is what makes them searchable
    searchables.each(&:publish!)
    switch_to_host(organization.host)
    visit search_path
  end

  it "renders the assemblies section with the assemblies found" do
    within "#results" do
      expect(page).to have_css(".search__result h2", text: "Assemblies")
      expect(page).to have_css(".search__result div.card__search", count: searchables.size)
    end
  end

  it "renders each assembly title as a link to the assembly page" do
    searchables.each do |assembly|
      expect(page).to have_link(translated(assembly.title), href: Decidim::ResourceLocatorPresenter.new(assembly).path)
    end
  end

  it "renders the number of assemblies found" do
    expect(page).to have_css("#search-count h2", text: /#{searchables.size} results for the search: "#{term}"/)
  end

  context "when an assembly has published children" do
    let(:assembly) { searchables.first }
    let!(:child) { create(:assembly, organization:, parent: assembly, title: { en: "A child assembly" }) }

    before do
      child.publish!
      visit search_path
    end

    it "renders the children metadata for that assembly" do
      within "div.card__search#assembly_#{assembly.id}" do
        expect(page).to have_css(".card__search-metadata", text: "1 assembly")
      end
    end
  end

  context "when the assembly is not published" do
    let!(:unpublished) { create(:assembly, :unpublished, organization:, title: { en: "A doggo unpublished assembly" }) }

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

  context "when an assembly title contains HTML" do
    let!(:malicious) { create(:assembly, organization:, title: { en: 'A doggo <script>alert("XSS")</script> assembly' }) }

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
