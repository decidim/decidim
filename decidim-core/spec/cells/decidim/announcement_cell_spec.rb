# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AnnouncementCell, type: :cell do
    controller Decidim::LastActivitiesController

    context "when passing a non-empty string" do
      let(:announcement) { "My announcement" }

      it "renders the card" do
        html = cell("decidim/announcement", announcement).call
        expect(html).to have_css("div.flash[data-announcement]")
        expect(html).to have_text(announcement)
      end
    end

    context "when passing an icon" do
      let(:announcement) { { title: "My title", body: "My body" } }

      it "renders the icon, the title and the body" do
        html = cell("decidim/announcement", announcement, callout_class: "info", icon: "information-line").call
        expect(html).to have_css("div.flash.flash--with-icon.info[data-announcement]")
        expect(html).to have_css(".flash__icon svg")
        expect(html).to have_css(".flash__content .flash__title", text: "My title")
        expect(html).to have_css(".flash__content .flash__message", text: "My body")
      end

      it "renders a close button when closable" do
        html = cell("decidim/announcement", announcement, callout_class: "info", icon: "information-line", closable: true).call
        expect(html).to have_css("div.flash[data-announcement][data-alert-box]")
        expect(html).to have_css("button.close-button[data-close][aria-label='Dismiss notification'] svg")
      end

      it "does not render a close button by default" do
        html = cell("decidim/announcement", announcement, callout_class: "info", icon: "information-line").call
        expect(html).to have_no_css("[data-alert-box]")
        expect(html).to have_no_button(class: "close-button")
      end

      it "does not render an icon when not requested" do
        html = cell("decidim/announcement", announcement, callout_class: "info").call
        expect(html).to have_no_css(".flash__icon")
        expect(html).to have_no_css(".flash--with-icon")
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
        expect(html).to have_css("div.flash[data-announcement]")
        expect(html).to have_text("My announcement")
      end
    end

    context "when passing a translations hash with some empty locales" do
      let(:announcement) { { en: "My announcement", ca: "" } }

      it "renders the card" do
        html = cell("decidim/announcement", announcement).call
        expect(html).to have_css("div.flash[data-announcement]")
        expect(html).to have_text("My announcement")
      end
    end
  end
end
