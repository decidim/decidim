# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::VotingCell, type: :cell do
  controller Decidim::Votings::VotingsController

  subject { my_cell.call }

  let(:my_cell) { cell("decidim/votings/voting", model) }
  let!(:voting) { create(:voting, :published, :ongoing) }
  let!(:current_user) { create(:user, :confirmed, organization: model.organization) }

  before do
    allow(controller).to receive(:current_user).and_return(current_user)
  end

  context "when rendering a voting" do
    let(:model) { voting }

    it "renders the card" do
      expect(subject).to have_css(".card--voting")
    end

    it "renders the title and text" do
      expect(subject).to have_css(".card__title")
      expect(subject).to have_css(".card__text")
    end
  end
end
