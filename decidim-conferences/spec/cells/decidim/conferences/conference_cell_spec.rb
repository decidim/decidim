# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe ConferenceCell, type: :cell do
    controller Decidim::Conferences::ConferencesController

    subject { cell("decidim/conferences/conference_m", model).call }

    let(:model) { create(:conference) }

    context "when rendering" do
      it "renders the card" do
        expect(subject).to have_css(".card--conference")
      end
    end
  end
end
