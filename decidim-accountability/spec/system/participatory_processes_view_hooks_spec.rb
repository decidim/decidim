# frozen_string_literal: true

require "spec_helper"

describe "Results in process home" do
  include_context "with a component"
  let(:manifest_name) { "accountability" }
  let(:results_count) { 5 }

  before do
    create(:content_block, organization:, scope_name: :participatory_process_homepage, manifest_name: :highlighted_results, scoped_resource_id: participatory_process.id)
  end

  context "when there are no results" do
    it "does not show the highlighted results section" do
      visit resource_locator(participatory_process).path
      expect(page).not_to have_css("#participatory-process-homepage-highlighted-results")
    end
  end

  context "when there are results" do
    let!(:results) do
      create_list(:result, results_count, component:)
    end

    it "shows the highlighted results section" do
      visit resource_locator(participatory_process).path

      within "#participatory-process-homepage-highlighted-results" do
        expect(page).to have_css("[id^='accountability__result_']", count: 4)

        results_titles = results.map { |r| translated(r.title) }
        highlighted_results = page.all(".card__list-content .card__list-title").map(&:text)
        expect(results_titles).to include(*highlighted_results)
      end
    end
  end
end
