# frozen_string_literal: true

require "spec_helper"

module Decidim::Initiatives
  describe InitiativeGCell, type: :cell do
    controller Decidim::Initiatives::InitiativesController

    subject { cell_html }

    let(:my_cell) { cell("decidim/initiatives/initiative_g", initiative, context: { show_space: }) }
    let(:cell_html) { my_cell.call }
    let(:state) { :open }
    let(:organization) { create(:organization) }
    let!(:initiative) { create(:initiative, organization:, state:) }
    let(:user) { create(:user, organization: initiative.organization) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    context "when rendering" do
      let(:show_space) { false }

      it "renders the card" do
        expect(subject).to have_css("[id^=initiative]")
      end

      shared_examples_for "card shows signatures" do
        it "shows signatures" do
          expect(subject).to have_css("[data-progress-bar]")
        end
      end

      shared_examples_for "card does not show signatures" do
        it "does not show signatures" do
          expect(subject).to have_no_css("[data-progress-bar]")
        end
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
