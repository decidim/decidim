# frozen_string_literal: true

require "spec_helper"

module Decidim::Proposals
  describe ProposalMetadataCell, type: :cell do
    controller Decidim::Proposals::ProposalsController

    let(:component) { create(:proposal_component) }
    let(:proposal) { create(:proposal, :evaluating, component:) }
    let(:my_cell) { cell("decidim/proposals/proposal_metadata", proposal) }

    it "preserves generated state label markup for map metadata" do
      state_item = my_cell.send(:items_for_map).find { |item| item[:html].present? }

      expect(state_item[:html]).to include("label")
      expect(state_item[:text]).to include("label")
    end

    it "keeps author names as text for map metadata" do
      author_item = my_cell.send(:items_for_map).first

      expect(author_item[:html]).to be_nil
      expect(author_item[:text]).to eq(proposal.authors.first.name)
    end
  end
end
