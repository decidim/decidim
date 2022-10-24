# frozen_string_literal: true

require "spec_helper"

describe "Proposals in process home", type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }
  let(:proposals_count) { 2 }
  let(:highlighted_proposals) { proposals_count * 2 }

  before do
    allow(Decidim::Proposals.config)
      .to receive(:participatory_space_highlighted_proposals_limit)
      .and_return(highlighted_proposals)
  end

  context "when there are no proposals" do
    it "does not show the highlighted proposals section" do
      visit resource_locator(participatory_process).path
      expect(page).not_to have_css(".highlighted_proposals")
    end
  end

  context "when there are proposals" do
    let!(:proposals) { create_list(:proposal, proposals_count, component:) }
    let!(:drafted_proposals) { create_list(:proposal, proposals_count, :draft, component:) }
    let!(:hidden_proposals) { create_list(:proposal, proposals_count, :hidden, component:) }
    let!(:withdrawn_proposals) { create_list(:proposal, proposals_count, :withdrawn, component:) }

    it "shows the highlighted proposals section" do
      visit resource_locator(participatory_process).path

      within ".highlighted_proposals" do
        expect(page).to have_css(".card--proposal", count: proposals_count)

        proposals_titles = proposals.map(&:title).map { |title| translated(title) }
        drafted_proposals_titles = drafted_proposals.map(&:title).map { |title| translated(title) }
        hidden_proposals_titles = hidden_proposals.map(&:title).map { |title| translated(title) }
        withdrawn_proposals_titles = withdrawn_proposals.map(&:title).map { |title| translated(title) }

        highlighted_proposals = page.all(".card--proposal .card__title").map(&:text)
        expect(proposals_titles).to include(*highlighted_proposals)
        expect(drafted_proposals_titles).not_to include(*highlighted_proposals)
        expect(hidden_proposals_titles).not_to include(*highlighted_proposals)
        expect(withdrawn_proposals_titles).not_to include(*highlighted_proposals)
      end
    end

    context "and there are more proposals than those that can be shown" do
      let!(:proposals) { create_list(:proposal, highlighted_proposals + 2, component:) }

      it "shows the amount of proposals configured" do
        visit resource_locator(participatory_process).path

        within ".highlighted_proposals" do
          expect(page).to have_css(".card--proposal", count: highlighted_proposals)

          proposals_titles = proposals.map(&:title).map { |title| translated(title) }
          highlighted_proposals = page.all(".card--proposal .card__title").map(&:text)
          expect(proposals_titles).to include(*highlighted_proposals)
        end
      end
    end
  end
end
