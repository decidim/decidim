# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe ConferenceCell, type: :cell do
    controller Decidim::Conferences::ConferencesController

    let!(:conference) { create(:conference) }

    context "when rendering" do
      it "renders the card" do
        html = cell("decidim/conferences/conference", conference).call
        expect(html).to have_css(".card--conference")
      end
    end
  end
end
