# frozen_string_literal: true

require "spec_helper"

module Decidim::Initiatives
  describe InitiativeMCell, type: :cell do
    controller Decidim::Initiatives::InitiativesController

    subject { cell_html }

    let(:my_cell) { cell("decidim/initiatives/initiative_m", initiative, context: { show_space: show_space }) }
    let(:cell_html) { my_cell.call }
    let!(:initiative) { create(:initiative, hashtag: "my_hashtag") }
    let(:user) { create :user, organization: initiative.organization }

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    context "when rendering" do
      let(:show_space) { false }

      it "renders the card" do
        expect(subject).to have_css(".card--initiative")
      end

      it "renders the hashtag" do
        expect(subject).to have_content("#my_hashtag")
      end
    end
  end
end
