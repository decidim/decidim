# frozen_string_literal: true

require "spec_helper"

module Decidim::Proposals
  describe ProposalMCell, type: :cell do
    controller Decidim::Proposals::ProposalsController

    subject { cell_html }

    let(:my_cell) { cell("decidim/proposals/proposal_m", proposal, context: { show_space: show_space }) }
    let(:cell_html) { my_cell.call }
    let(:created_at) { Time.current - 1.month }
    let(:published_at) { Time.current }
    let!(:proposal) { create(:proposal, created_at: created_at, published_at: published_at) }
    let(:model) { proposal }
    let(:user) { create :user, organization: proposal.participatory_space.organization }

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    it_behaves_like "has space in m-cell"

    context "when rendering" do
      let(:show_space) { false }

      it "renders the card" do
        expect(subject).to have_css(".card--proposal")
      end

      it "renders the published_at date" do
        published_date = I18n.l(published_at.to_date, format: :decidim_short)
        creation_date = I18n.l(created_at.to_date, format: :decidim_short)

        expect(subject).to have_css(".creation_date_status", text: published_date)
        expect(subject).not_to have_css(".creation_date_status", text: creation_date)
      end
    end
  end
end
