# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::ElectionCell, type: :cell do
  controller Decidim::Elections::ElectionsController

  subject { my_cell.call }

  let(:my_cell) { cell("decidim/elections/election", model) }
  let!(:election) { create(:election, :complete, :published, :ongoing) }
  let!(:current_user) { create(:user, :confirmed, organization: model.participatory_space.organization) }

  before do
    allow(controller).to receive(:current_user).and_return(current_user)
  end

  context "when rendering an election" do
    let(:model) { election }

    it "renders the card" do
      expect(subject).to have_css(".card--election")
    end

    it "renders the title and text" do
      expect(subject).to have_css(".card__title")
      expect(subject).to have_css(".card__text")
    end
  end
end
