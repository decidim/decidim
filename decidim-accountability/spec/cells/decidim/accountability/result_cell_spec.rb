# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability
  describe ResultCell, type: :cell do
    controller Decidim::Accountability::ResultsController

    let!(:result) { create(:result) }
    let(:display_progress) { true }
    let(:component_settings) do
      double(
        display_progress_enabled?: display_progress
      )
    end

    before do
      allow(controller).to receive(:component_settings).and_return(component_settings)
    end

    context "when rendering" do
      let(:html) { cell("decidim/accountability/result", result).call }

      it "renders the card" do
        expect(html).to have_css(".card__list")
      end

      it "renders the progress" do
        expect(html).to have_css("div.accountability__progress")
      end

      context "when displaying progress is disabled in component settings" do
        let(:display_progress) { false }

        it "does not render the progress" do
          expect(html).not_to have_css("div.accountability__progress")
        end
      end
    end
  end
end
