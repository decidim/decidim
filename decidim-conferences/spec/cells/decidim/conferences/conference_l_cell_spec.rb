# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe ConferenceLCell, type: :cell do
    controller Decidim::Conferences::ConferencesController

    subject { cell("decidim/conferences/conference_l", model).call }

    let(:model) { create(:conference) }

    context "when rendering" do
      let(:show_space) { false }

      it "renders the card" do
        expect(subject).to have_css("[id^='conference']")
      end
    end
  end
end
