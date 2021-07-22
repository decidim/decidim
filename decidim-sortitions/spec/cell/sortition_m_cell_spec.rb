# frozen_string_literal: true

require "spec_helper"

module Decidim::Sortitions
  describe SortitionMCell, type: :cell do
    controller Decidim::Sortitions::SortitionsController

    let(:component) { create(:sortition_component) }
    let!(:sortition) { create(:sortition) }
    let(:model) { sortition }
    let(:the_cell) { cell("decidim/sortitions/sortition_m", sortition, context: { show_space: show_space }) }
    let(:cell_html) { the_cell.call }

    it_behaves_like "has space in m-cell"

    context "when rendering" do
      let(:show_space) { false }

      it "renders the card" do
        expect(cell_html).to have_css(".card--sortition")
      end
    end
  end
end
