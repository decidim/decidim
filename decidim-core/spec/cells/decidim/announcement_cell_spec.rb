# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AnnouncementCell, type: :cell do
    controller Decidim::LastActivitiesController

    context "when passing a non-empty string" do
      let(:announcement) { "My announcement" }

      it "renders the card" do
        html = cell("decidim/announcement", announcement).call
        expect(html).to have_css("div.callout.js-announcement")
        expect(html).to have_text(announcement)
      end
    end

    context "when passing an empty string" do
      let(:announcement) { "" }

      it "does not render the card" do
        html = cell("decidim/announcement", announcement).call
        expect(html).to render_nothing
      end
    end

    context "when passing an empty translations hash" do
      let(:announcement) { { en: "" } }

      it "does not render the card" do
        html = cell("decidim/announcement", announcement).call
        expect(html).to render_nothing
      end
    end

    context "when passing a non-empty translations hash" do
      let(:announcement) { { en: "My announcement", ca: "Translated value" } }

      it "renders the card" do
        html = cell("decidim/announcement", announcement).call
        expect(html).to have_css("div.callout.js-announcement")
        expect(html).to have_text("My announcement")
      end
    end
  end
end
