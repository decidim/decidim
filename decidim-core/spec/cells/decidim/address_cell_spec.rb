# frozen_string_literal: true

require "spec_helper"

describe Decidim::AddressCell, type: :cell do
  controller Decidim::ApplicationController

  subject { my_cell.call }

  let(:my_cell) { cell("decidim/address", model) }
  let(:address_text) { "Foo bar Street, 1" }
  let(:js_alert) { "<script>alert(1)</script>" }
  let(:address) { "#{address_text}#{js_alert}" }
  let(:latitude) { 41.378481 }
  let(:longitude) { 2.1879618 }
  let(:model) { create(:dummy_resource, address:, latitude:, longitude:) }
  let(:hint_text) { "Lorem ipsum dolor sit amet consectetur" }
  let(:location_hints) { "#{hint_text}#{js_alert}" }
  let(:location_text) { "This is my location" }
  let(:location) { "#{location_text}#{js_alert}" }

  let(:icondata_address) { subject.find(".address") }

  # Fixed instants. They are rendered in the time zone the cell is rendered in,
  # which is the organization one set by `use_organization_time_zone`.
  let(:start_time) { Time.parse("2026-01-15 15:04:00 UTC").in_time_zone }
  let(:end_time) { Time.parse("2026-01-15 18:30:00 UTC").in_time_zone }

  context "with a location" do
    before do
      allow(model).to receive(:location_hints).and_return location_hints
      allow(model).to receive(:location).and_return location
    end

    it "renders a resource address and related fields" do
      expect(icondata_address).to have_text(address_text)
      expect(icondata_address).to have_text(hint_text)
      expect(icondata_address).to have_text(location_text)
      expect(icondata_address.to_s).not_to match(/<script>/i)
      expect(icondata_address).to have_no_text(model.latitude)
      expect(icondata_address).to have_no_text(model.longitude)
    end
  end

  context "when address is pending" do
    let(:location) { { "ca" => "", "en" => "", "es" => "", "machine_translations" => { "es" => "Location" } } }

    before do
      allow(model).to receive(:location).and_return location
      allow(model).to receive(:pending_location?).and_return(true)
    end

    it "renders pending address text" do
      expect(subject.find(".address__location")).to have_text(I18n.t("show.pending_address", scope: "decidim.meetings.meetings"))
    end
  end

  context "with an online meeting url" do
    let(:my_cell) { cell("decidim/address", model, online: true) }
    let(:model) { create(:dummy_resource) }
    let(:online_meeting_url) { "https://decidim.org" }

    before do
      allow(model).to receive(:online?).and_return true
      allow(model).to receive(:type_of_meeting).and_return :online
      allow(model).to receive(:iframe_access_level_allowed_for_user?).and_return true
      allow(model).to receive(:online_meeting_url).and_return online_meeting_url
    end

    it "renders the URL" do
      expect(subject).to have_text "https://decidim.org"
    end

    context "with a malformed URL" do
      let(:online_meeting_url) { "https://decidim.org/?v=h<script>alert(1)</script>" }

      it "renders the escaped URL" do
        expect(subject).to have_text "https://decidim.org/?v=h%3Cscript%3Ealert(1)%3C/script%3E"
      end
    end
  end

  context "with start_time and end_time" do
    before do
      allow(model).to receive(:start_time).and_return start_time
      allow(model).to receive(:end_time).and_return end_time
    end

    let(:time_section) { subject.all("li").last }
    let(:tooltips) { time_section.all("span[data-controller='tooltip']") }
    let(:start_time_text) { tooltips.first.text }
    let(:end_time_text) { tooltips.last.text }
    let(:tooltip_titles) { tooltips.map { |tooltip| Nokogiri::HTML5.fragment(tooltip["data-tooltip-tooltip-value"]).text } }

    it "renders both times separated" do
      expect(subject).to have_css("li", count: 2)
      expect(time_section.text.squish).to eq("03:04 PM - 06:30 PM UTC")
    end

    it "renders the start time with the 12-hour clock and the meridiem" do
      expect(start_time_text).to eq("03:04 PM")
      expect(start_time_text).not_to eq("15:04 PM")
    end

    it "renders the end time with the meridiem and the time zone" do
      expect(end_time_text).to eq("06:30 PM UTC")
    end

    it "renders the full date and the time zone offset in the tooltips" do
      expect(tooltip_titles).to eq(
        [
          "15-01-2026 03:04 PM UTC (GMT +00:00)",
          "15-01-2026 06:30 PM UTC (GMT +00:00)"
        ]
      )
    end

    it "escapes the tooltip markup rendered in the data attribute" do
      expect(subject.to_s).to include("&lt;p class=\"bottom\"")
      expect(subject.to_s).not_to match(/<script>/i)
    end

    context "when the times are at midnight and noon" do
      let(:start_time) { Time.parse("2026-01-15 00:00:00 UTC").in_time_zone }
      let(:end_time) { Time.parse("2026-01-15 12:00:00 UTC").in_time_zone }

      it "renders 12 AM and 12 PM instead of 00 AM and 00 PM" do
        expect(start_time_text).to eq("12:00 AM")
        expect(end_time_text).to eq("12:00 PM UTC")
      end
    end

    context "when the rendering time zone is the organization one", tz: "Madrid" do
      it "renders both times in that time zone" do
        expect(start_time_text).to eq("04:04 PM")
        expect(end_time_text).to eq("07:30 PM CET")
      end

      it "renders the time zone abbreviation and offset in the tooltips" do
        expect(tooltip_titles).to eq(
          [
            "15-01-2026 04:04 PM CET (GMT +01:00)",
            "15-01-2026 07:30 PM CET (GMT +01:00)"
          ]
        )
      end
    end

    context "when the time zone observes daylight saving time", tz: "Madrid" do
      let(:start_time) { Time.parse("2026-07-15 15:04:00 UTC").in_time_zone }
      let(:end_time) { Time.parse("2026-07-15 18:30:00 UTC").in_time_zone }

      it "renders the daylight saving time abbreviation" do
        expect(start_time_text).to eq("05:04 PM")
        expect(end_time_text).to eq("08:30 PM CEST")
        expect(tooltip_titles.last).to eq("15-07-2026 08:30 PM CEST (GMT +02:00)")
      end
    end

    context "when the time zone moves the time to the next day", tz: "Tokyo" do
      it "renders the date as seen from that time zone" do
        expect(start_time_text).to eq("12:04 AM")
        expect(end_time_text).to eq("03:30 AM JST")
        expect(tooltip_titles.first).to eq("16-01-2026 12:04 AM JST (GMT +09:00)")
      end
    end

    context "when the time zone has a half-hour offset", tz: "New Delhi" do
      it "renders the offset including the minutes" do
        expect(start_time_text).to eq("08:34 PM")
        expect(end_time_text).to eq("12:00 AM IST")
        expect(tooltip_titles.last).to eq("16-01-2026 12:00 AM IST (GMT +05:30)")
      end
    end

    context "when the time zone is behind UTC", tz: "Hawaii" do
      it "renders the negative offset" do
        expect(start_time_text).to eq("05:04 AM")
        expect(end_time_text).to eq("08:30 AM HST")
        expect(tooltip_titles.last).to eq("15-01-2026 08:30 AM HST (GMT -10:00)")
      end
    end

    context "when the locale does not define the time formats" do
      it "falls back to the English formats" do
        I18n.with_locale(:ca) do
          expect(start_time_text).to eq("03:04 PM")
          expect(end_time_text).to eq("06:30 PM UTC")
        end
      end
    end

    context "when one of the times is blank" do
      context "with a blank start_time" do
        let(:start_time) { nil }

        it "does not render the time section" do
          expect(subject).to have_css("li", count: 1)
        end
      end

      context "with a blank end_time" do
        let(:end_time) { nil }

        it "does not render the time section" do
          expect(subject).to have_css("li", count: 1)
        end
      end
    end
  end

  context "when the model does not respond to the times" do
    it "does not render the time section" do
      expect(subject).to have_css("li", count: 1)
    end

    it "still renders the address" do
      expect(icondata_address).to have_text(address_text)
    end
  end

  context "when the model responds only to start_time" do
    before do
      allow(model).to receive(:start_time).and_return start_time
    end

    it "does not render the time section" do
      expect(subject).to have_css("li", count: 1)
    end
  end

  context "when the model responds only to end_time" do
    before do
      allow(model).to receive(:end_time).and_return end_time
    end

    it "does not render the time section" do
      expect(subject).to have_css("li", count: 1)
    end
  end
end
