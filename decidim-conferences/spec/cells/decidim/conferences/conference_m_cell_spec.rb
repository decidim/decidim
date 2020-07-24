# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/space_cell_changes_button_text_cta"

module Decidim::Conferences
  describe ConferenceMCell, type: :cell do
    controller Decidim::Conferences::ConferencesController

    subject { cell("decidim/conferences/conference_m", model).call }

    let(:model) { create(:conference) }

    context "when rendering" do
      let(:show_space) { false }

      it "renders the card" do
        expect(subject).to have_css(".card--conference")
      end

      it_behaves_like "space cell changes button text CTA"
    end
  end
end
