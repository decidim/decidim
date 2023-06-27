# frozen_string_literal: true

require "spec_helper"

module Decidim::Proposals
  describe ProposalGCell, type: :cell do
    controller Decidim::Proposals::ProposalsController
    include Decidim::TranslatableAttributes

    subject { cell("decidim/proposals/proposal_g", model).call }

    let!(:proposal) { create(:proposal) }
    let(:model) { proposal }

    context "when rendering" do
      it "renders the card" do
        expect(subject).to have_content(translated_attribute(model.title))
      end
    end
  end
end
