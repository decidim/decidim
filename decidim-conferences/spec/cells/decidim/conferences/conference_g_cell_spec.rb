# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe ConferenceGCell, type: :cell do
    controller Decidim::Conferences::ConferencesController
    include Decidim::TranslatableAttributes

    subject { cell("decidim/conferences/conference_g", model).call }

    let(:model) { create(:conference) }

    context "when rendering" do
      it "renders the card" do
        expect(subject).to have_content(translated_attribute(model.title))
      end
    end
  end
end
