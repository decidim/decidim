# frozen_string_literal: true

require "spec_helper"

describe "Proposals in process home", type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }
  let(:proposals_count) { 5 }

  context "when there are no proposals" do
    it "does not show the highlighted proposals section" do
      visit resource_locator(participatory_process).path
      expect(page).not_to have_css(".highlighted_proposals")
    end
  end

  context "when there are proposals" do
    let!(:proposals) do
      create_list(:proposal, proposals_count, component: component)
    end

    it "shows the highlighted proposals section" do
      visit resource_locator(participatory_process).path

      within ".highlighted_proposals" do
        expect(page).to have_css(".card--proposal", count: 4)

        proposals_titles = proposals.map(&:title)
        highlighted_proposals = page.all(".card--proposal .card__title").map(&:text)
        expect(proposals_titles).to include(*highlighted_proposals)
      end
    end
  end
end
