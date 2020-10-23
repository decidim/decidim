# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability
  describe ResultCell, type: :cell do
    controller Decidim::Accountability::ResultsController

    let!(:result) { create(:result) }

    context "when rendering" do
      it "renders the card" do
        html = cell("decidim/accountability/result", result).call
        expect(html).to have_css(".card--result")
      end
    end
  end
end
