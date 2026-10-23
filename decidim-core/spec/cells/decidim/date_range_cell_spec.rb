# frozen_string_literal: true

require "spec_helper"

describe Decidim::DateRangeCell, type: :cell do
  subject { my_cell.call }

  controller Decidim::Debates::DebatesController

  let(:my_cell) { cell("decidim/date_range", model) }
  let!(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization:) }
  let(:model) { { start: start_time, end: end_time } }
  let(:base_time) { Time.zone.parse(Time.zone.now.strftime("%Y-%m-%d 12:00:00")) }
  let(:start_time) { base_time - 1.hour }
  let(:start_time_past_year) { base_time - 1.year }
  let(:end_time_same_date) { base_time + 1.hour }
  let(:end_time_different_date) { base_time + 1.day }
  let(:end_time_different_year) { base_time + 1.year }
  let(:end_time_past_year) { start_time_past_year + 1.hour }

  context "when rendering a date" do
    let(:end_time) { end_time_same_date }

    it "renders a Date card" do
      expect(subject).to have_css("[data-date-container]")
    end
  end

  context "when start and end time are on the same date" do
    let(:end_time) { end_time_same_date }

    it "renders only one date and time" do
      expect(subject).to have_css("[data-date]", count: 1)
      expect(subject).to have_css("[data-time]", count: 1)
    end
  end

  context "when start and end time are on different dates" do
    let(:end_time) { end_time_different_date }

    it "renders the two dates and times" do
      expect(subject).to have_css("[data-date]", count: 2)
      expect(subject).to have_css("[data-time]", count: 2)
    end
  end

  context "when start and end time are on different years" do
    let(:end_time) { end_time_different_year }

    it "renders the two dates and times" do
      expect(subject).to have_css("[data-date]", count: 2)
      expect(subject).to have_css("[data-time]", count: 2)
    end

    it "renders two year elements" do
      expect(subject).to have_text(start_time.year.to_s)
      expect(subject).to have_text(end_time.year.to_s)
    end
  end

  context "when start time is not the current year" do
    let(:start_time) { start_time_past_year }
    let(:end_time) { end_time_past_year }

    it "renders two year elements" do
      expect(subject).to have_text(start_time.year.to_s)
      expect(subject).to have_text(end_time.year.to_s)
    end
  end

  context "when rendering the times" do
    let(:start_time) { Time.parse("2026-01-15 15:04:00 UTC").in_time_zone }
    let(:end_time) { Time.parse("2026-01-15 18:30:00 UTC").in_time_zone }

    it "renders both times with the localized time_of_day format" do
      expect(subject.find("[data-time]").text.squish).to eq("15:04 - 18:30")
    end

    it "renders the times in the current time zone", tz: "Madrid" do
      expect(subject.find("[data-time]").text.squish).to eq("16:04 - 19:30")
    end

    context "when the times are on different dates" do
      let(:end_time) { Time.parse("2026-01-16 18:30:00 UTC").in_time_zone }

      it "renders each time in its own element" do
        expect(subject.all("[data-time]").map { |node| node.text.squish }).to eq(["15:04", "18:30"])
      end
    end

    context "when the time zone conversion moves the end time to another day", tz: "Tokyo" do
      before do
        travel_to(Time.zone.parse("2026-01-15 12:00:00 UTC"))
      end

      let(:start_time) { Time.parse("2026-01-15 14:00:00 UTC") }
      let(:end_time) { Time.parse("2026-01-15 18:00:00 UTC") }

      it "renders both dates, as the end time falls on the next day in the rendering time zone" do
        expect(subject).to have_css("[data-date]", count: 2)
        expect(subject.all("[data-date]").map { |node| node.text.squish }).to eq(["15 January", "16 January"])
        expect(subject.all("[data-time]").map { |node| node.text.squish }).to eq(["23:00", "03:00"])
      end
    end

    context "when the model values are Dates instead of times" do
      let(:start_time) { Date.parse("2026-01-15") }
      let(:end_time) { Date.parse("2026-01-16") }

      it "renders midnight in the current time zone" do
        expect(subject.all("[data-time]").map { |node| node.text.squish }).to eq(["00:00", "00:00"])
      end
    end

    context "when rendering the month" do
      before do
        travel_to(Time.zone.parse("2026-01-15 12:00:00 UTC"))
      end

      let(:start_time) { Time.zone.parse("2026-01-15 15:04:00 UTC") }
      let(:end_time) { Time.zone.parse("2026-01-15 18:30:00 UTC") }

      it "renders the month without the year when both dates are in the current year" do
        expect(subject.find("[data-month]").text.squish).to eq("January")
      end

      context "when the time zone conversion moves the start time to the current year", tz: "Tokyo" do
        let(:start_time) { Time.parse("2025-12-31 23:00:00 UTC") }
        let(:end_time) { Time.parse("2026-01-01 00:30:00 UTC") }

        it "renders the month without the year, as both dates are in the current year in the rendering time zone" do
          expect(subject).to have_css("[data-date]", count: 1)
          expect(subject.all("[data-month]").map { |node| node.text.squish }).to eq(["January"])
        end
      end

      context "when one of the dates is in another year" do
        let(:end_time) { Time.zone.parse("2027-01-15 18:30:00 UTC") }

        it "renders the month with the year for both dates" do
          expect(subject.all("[data-month]").map { |node| node.text.squish }).to eq(["January 2026", "January 2027"])
        end
      end
    end
  end
end
