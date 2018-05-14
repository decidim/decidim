# frozen_string_literal: true

require "spec_helper"

module Decidim::Proposals
  describe ProposalCell, type: :cell do
    controller Decidim::Proposals::ProposalsController

    let!(:proposal) { create(:proposal) }

    context "when rendering" do
      it "renders the card" do
        html = cell("decidim/proposals/proposal_m", proposal).call
        expect(html).to have_css(".card--proposal")
      end
    end
  end
end
