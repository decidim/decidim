# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::ProposalCell, type: :cell do
  controller Decidim::Proposals::ProposalsController

  let!(:official_proposal) { create(:proposal, :official) }
  let!(:user_proposal) { create(:proposal) }
  let(:current_user) { create(:user, :confirmed, organization: component.participatory_space.organization) }

  context "when rendering an official proposal" do
    it "renders the card" do
      html = cell("decidim/proposals/proposal", official_proposal).call
      expect(html).to have_css(".card--proposal")
    end
  end

  context "when rendering a user proposal" do
    it "renders the card" do
      html = cell("decidim/proposals/proposal", user_proposal).call
      expect(html).to have_css(".card--proposal")
    end
  end
end
