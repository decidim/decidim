# frozen_string_literal: true

require "spec_helper"

describe "Search budgets projects" do
  include_context "with a component"

  let(:manifest_name) { "budgets" }
  let(:budget) { create(:budget, component:) }
  let(:search_term) { "doggo" }
  let(:search_path) { decidim.search_path(term: search_term, filter: { with_resource_type: "Decidim::Budgets::Project" }) }
  let(:child_taxonomy) { create(:taxonomy, parent: taxonomy, organization:, skip_injection: true) }
  let!(:child_taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: child_taxonomy) }
  let!(:projects) do
    3.times.map do |i|
      create(:project, budget:, taxonomies: [taxonomy, child_taxonomy], title: { en: "A doggo project #{i}" })
    end
  end

  before do
    visit search_path
  end

  it "renders the projects section with the projects found" do
    within "#results" do
      expect(page).to have_css(".search__result h2", text: "Projects")
      expect(page).to have_css(".search__result div.card__search", count: projects.size)
    end
  end

  it "renders each project title as a link to the project page" do
    projects.each do |project|
      expect(page).to have_link(translated(project.title), href: Decidim::ResourceLocatorPresenter.new([budget, project]).path)
    end
  end

  it "renders the taxonomies of each project" do
    projects.each do |project|
      within "div.card__search#project_#{project.id}" do
        expect(page).to have_css(".card__search-metadata", text: translated(taxonomy.name))
        expect(page).to have_css(".card__search-metadata", text: translated(child_taxonomy.name))
      end
    end
  end

  it "escapes the project title instead of rendering it" do
    malicious = create(:project, budget:, title: { en: 'A doggo <script>alert("XSS")</script> project' })

    visit search_path

    expect(page).to have_css(".card__search-title", text: '<script>alert("XSS")</script>')
    expect(page).to have_no_css(".card__search-title script")
    expect(page).to have_link(translated(malicious.title), href: Decidim::ResourceLocatorPresenter.new([budget, malicious]).path)
  end
end
