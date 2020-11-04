# frozen_string_literal: true

require "spec_helper"

module Decidim::Proposals
  describe ReportedContentCell, type: :cell do
    controller Decidim::Proposals::ProposalsController

    let!(:proposal) { create(:proposal, title: { "en" => "a nice title" }, body: { "en" => "let's do this!" }) }

    context "when rendering" do
      it "renders the proposal's title and body" do
        html = cell("decidim/reported_content", proposal).call
        expect(html).to have_content("a nice title")
        expect(html).to have_content("let's do this!")
      end
    end
  end
end
