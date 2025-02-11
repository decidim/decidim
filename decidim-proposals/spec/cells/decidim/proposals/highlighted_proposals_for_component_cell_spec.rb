# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::HighlightedProposalsForComponentCell, type: :cell do
  controller Decidim::Proposals::ProposalsController

  subject { my_cell.call }

  let(:my_cell) { cell("decidim/proposals/highlighted_proposals_for_component", model) }
  let!(:official_proposal) { create(:proposal, :official) }
  let!(:user_proposal) { create(:proposal) }
  let!(:current_user) { create(:user, :confirmed, organization: model.participatory_space.organization) }
  let(:model) { create(:proposal_component) }
  let!(:proposal) { create(:proposal, title: { en: "A nice title" }, component: model) }

  before do
    allow(controller).to receive(:current_user).and_return(current_user)
  end

  context "when no proposals" do
    let!(:proposal) { nil }

    it "renders nothing" do
      expect(subject).to have_no_content("A nice title")
      expect(subject).to have_no_content("Last proposals")
      expect(subject).to have_no_css(".card__list-title", count: 1)
    end
  end

  context "when no published proposals" do
    let!(:proposal) { create(:proposal, :unpublished, title: { en: "A nice title" }, component: model) }

    it "renders the proposals" do
      expect(subject).to have_no_content("A nice title")
      expect(subject).to have_no_content("Last proposals")
      expect(subject).to have_no_css(".card__list-title", count: 1)
    end
  end

  context "when proposals are hidden" do
    let!(:proposal) { create(:proposal, :hidden, title: { en: "A nice title" }, component: model) }

    it "renders the proposals" do
      expect(subject).to have_no_content("A nice title")
      expect(subject).to have_no_content("Last proposals")
      expect(subject).to have_no_css(".card__list-title", count: 1)
    end
  end

  context "with proposals" do
    let!(:proposal2) { create(:proposal, title: { en: "Another nice title" }, component: model) }

    it "renders the proposals" do
      expect(subject).to have_content("A nice title")
      expect(subject).to have_content("Another nice title")
      expect(subject).to have_content("Last proposals")
      expect(subject).to have_css(".card__list-title", count: 2)
    end
  end

  context "when votes on proposals is enabled" do
    let(:model) { create(:proposal_component, :with_votes_enabled) }
    let!(:proposal) { create(:proposal, :with_votes, title: { en: "A nice title" }, component: model) }

    it "renders the proposals" do
      expect(subject).to have_content("A nice title")
      expect(subject).to have_content("Last proposals")
      expect(subject).to have_css(".card__list-title", count: 1)
    end
  end
end
