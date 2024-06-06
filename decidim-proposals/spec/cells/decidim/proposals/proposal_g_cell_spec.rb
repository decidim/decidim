# frozen_string_literal: true

require "spec_helper"

module Decidim::Proposals
  describe ProposalGCell, type: :cell do
    controller Decidim::Proposals::ProposalsController

    subject(:cell_html) { my_cell.call }

    let(:my_cell) { cell("decidim/proposals/proposal_g", proposal, card_size: :g) }
    let(:component) { create(:proposal_component, :with_attachments_allowed) }
    let!(:proposal) { create(:proposal, :evaluating, component:) }
    let(:user) { create(:user, organization: proposal.participatory_space.organization) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    describe "show" do
      it "renders the proposal state item with appropriate class" do
        expect(subject).to have_css("span.warning", text: "Evaluating")
      end

      it "renders the proposal title" do
        expect(subject).to have_content(translated_attribute(proposal.title))
      end

      context "when the proposal has an image" do
        let!(:attachment) { create(:attachment, attached_to: proposal) }

        it "renders the proposal with an image" do
          expect(subject).to have_css("img[src*='city']")
        end
      end

      context "when the proposal has no image" do
        before { allow(proposal).to receive(:attachments).and_return([]) }

        it "renders a placeholder image" do
          expect(subject).to have_css(".card__grid-img svg#ri-proposal-placeholder-card-g")
        end
      end
    end
  end
end
