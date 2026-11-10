# frozen_string_literal: true

require "spec_helper"

describe "Search budgets" do
  include_context "with a component"

  let(:manifest_name) { "budgets" }
  let(:search_term) { "doggo" }
  let(:search_path) { decidim.search_path(term: search_term, filter: { with_resource_type: "Decidim::Budgets::Budget" }) }
  let!(:budgets) do
    3.times.map do |i|
      create(:budget, component:, title: { en: "A doggo budget #{i}" })
    end
  end

  before do
    visit search_path
  end

  it "renders the budgets section with the budgets found" do
    within "#results" do
      expect(page).to have_css(".search__result h2", text: "Budgets")
      expect(page).to have_css(".search__result div.card__search", count: budgets.size)
    end
  end

  it "renders each budget title as a link to the budget page" do
    budgets.each do |budget|
      expect(page).to have_link(translated(budget.title), href: Decidim::ResourceLocatorPresenter.new(budget).path)
    end
  end

  it "renders the projects count for each budget" do
    budgets.each do |budget|
      create(:project, budget:)
      visit search_path

      within "div.card__search#budget_#{budget.id}" do
        expect(page).to have_css(".card__search-metadata", text: "1 project")
      end
    end
  end

  it "escapes the budget title instead of rendering it" do
    malicious = create(:budget, component:, title: { en: 'A doggo <script>alert("XSS")</script> budget' })

    visit search_path

    expect(page).to have_css(".card__search-title", text: '<script>alert("XSS")</script>')
    expect(page).to have_no_css(".card__search-title script")
    expect(page).to have_link(translated(malicious.title), href: Decidim::ResourceLocatorPresenter.new(malicious).path)
  end
end
