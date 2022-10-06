# frozen_string_literal: true

require "spec_helper"

describe "Results in process home", type: :system do
  include_context "with a component"
  let(:manifest_name) { "accountability" }
  let(:results_count) { 5 }

  context "when there are no results" do
    it "does not show the highlighted results section" do
      visit resource_locator(participatory_process).path
      expect(page).not_to have_css(".highlighted_results")
    end
  end

  context "when there are results" do
    let!(:results) do
      create_list(:result, results_count, component:)
    end

    it "shows the highlighted results section" do
      visit resource_locator(participatory_process).path

      within ".highlighted_results" do
        expect(page).to have_css(".card--list__item", count: 4)

        results_titles = results.map { |r| translated(r.title) }
        highlighted_results = page.all(".card--list__item .card--list__heading").map(&:text)
        expect(results_titles).to include(*highlighted_results)
      end
    end
  end
end
