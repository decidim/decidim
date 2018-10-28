# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe ConferenceCell, type: :cell do
    controller Decidim::Conferences::ConferencesController

    let!(:conference) { create(:conference) }
    let(:model) { conference }
    let(:cell_html) { cell("decidim/conferences/conference_m", conference).call }

    context "when rendering" do
      let(:show_space) { false }

      it "renders the card" do
        expect(cell_html).to have_css(".card--conference")
      end
    end
  end
end
