# frozen_string_literal: true

require "spec_helper"

module Decidim::Initiatives
  describe InitiativeMCell, type: :cell do
    controller Decidim::Initiatives::InitiativesController

    subject { cell_html }

    let(:my_cell) { cell("decidim/initiatives/initiative_m", initiative, context: { show_space: show_space }) }
    let(:cell_html) { my_cell.call }
    let(:state) { :published }
    let!(:initiative) { create(:initiative, hashtag: "my_hashtag", state: state) }
    let(:user) { create :user, organization: initiative.organization }

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    context "when rendering" do
      let(:show_space) { false }

      it "renders the card" do
        expect(subject).to have_css(".card--initiative")
      end

      shared_examples_for "card shows signatures" do
        it "shows signatures" do
          expect(subject).to have_css(".progress__bar__number")
          expect(subject).to have_css(".progress__bar__text")
          expect(subject.to_s).to include("signatures")
        end
      end

      shared_examples_for "card does not show signatures" do
        it "does not show signatures" do
          expect(subject).not_to have_css(".progress__bar__number")
          expect(subject).not_to have_css(".progress__bar__text")
          expect(subject.to_s).not_to include("signatures")
        end
      end

      it "renders the hashtag" do
        expect(subject).to have_content("#my_hashtag")
      end

      it_behaves_like "card shows signatures"

      context "when initiative state is rejected" do
        let(:state) { :rejected }

        it_behaves_like "card shows signatures"
      end

      context "when initiative state is accepted" do
        let(:state) { :accepted }

        it_behaves_like "card shows signatures"
      end

      context "when initiative state is created" do
        let(:state) { :created }

        it_behaves_like "card does not show signatures"
      end

      context "when initiative state is validating" do
        let(:state) { :validating }

        it_behaves_like "card does not show signatures"
      end

      context "when initiative state is discarded" do
        let(:state) { :discarded }

        it_behaves_like "card does not show signatures"
      end
    end
  end
end
