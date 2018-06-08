# frozen_string_literal: true

require "spec_helper"

module Decidim::Proposals
  describe ProposalMCell, type: :cell do
    controller Decidim::Proposals::ProposalsController

    subject { my_cell.call }

    let(:my_cell) { cell("decidim/proposals/proposal_m", proposal) }
    let!(:proposal) { create(:proposal) }
    let(:user) { create :user, organization: proposal.participatory_space.organization }

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    context "when rendering" do
      it "renders the card" do
        expect(subject).to have_css(".card--proposal")
      end
    end
  end
end
