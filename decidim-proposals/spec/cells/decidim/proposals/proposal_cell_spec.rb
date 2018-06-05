# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::ProposalCell, type: :cell do
  controller Decidim::Proposals::ProposalsController

  subject { my_cell.call }

  let(:my_cell) { cell("decidim/proposals/proposal", model) }
  let!(:official_proposal) { create(:proposal, :official) }
  let!(:user_proposal) { create(:proposal) }
  let!(:current_user) { create(:user, :confirmed, organization: model.participatory_space.organization) }

  before do
    allow(controller).to receive(:current_user).and_return(current_user)
  end

  context "when rendering an official proposal" do
    let(:model) { official_proposal }

    it "renders the card" do
      expect(subject).to have_css(".card--proposal")
    end
  end

  context "when rendering a user proposal" do
    let(:model) { user_proposal }

    it "renders the card" do
      expect(subject).to have_css(".card--proposal")
    end
  end
end
