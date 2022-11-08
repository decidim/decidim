# frozen_string_literal: true

require "spec_helper"

module Decidim::Debates
  describe DebateMCell, type: :cell do
    controller Decidim::Debates::DebatesController

    let!(:debate) { create(:debate) }
    let(:model) { debate }
    let(:the_cell) { cell("decidim/debates/debate_m", debate, context: { show_space: show_space }) }
    let(:cell_html) { the_cell.call }

    it_behaves_like "has space in m-cell"

    context "when rendering" do
      let(:show_space) { false }

      it_behaves_like "m-cell", :debate
    end
  end
end
