# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe DatesAndMapCell, type: :cell do
    controller Decidim::Meetings::MeetingsController

    subject { my_cell.call }

    let!(:meeting) { create(:meeting, :published, start_time: Time.new(2020, 10, 15, 10, 4, 5, 0), end_time: Time.new(2020, 10, 15, 12, 0, 0, 0)) }
    let(:my_cell) { cell("decidim/meetings/dates_and_map", meeting) }

    context "when rendering" do
      it "renders the calendar container" do
        expect(subject).to have_css(".meeting__calendar-container")
      end

      it "shows the start time's month" do
        expect(subject).to have_css(".meeting__calendar-month", text: "October")
      end

      it "shows the start time's day" do
        expect(subject).to have_css(".meeting__calendar-day", text: "15")
      end

      it "shows the start time's year" do
        expect(subject).to have_css(".meeting__calendar-year", text: "2020")
      end

      it "does not show separator" do
        expect(subject).to have_no_css(".meeting__calendar-separator")
      end
    end

    context "when meeting spans multiple days in the same month" do
      let!(:meeting) { create(:meeting, :published, start_time: Time.new(2020, 10, 15, 10, 0, 0, 0), end_time: Time.new(2020, 10, 17, 12, 0, 0, 0)) }

      it "shows the start day" do
        expect(subject).to have_css(".meeting__calendar-day", text: "15")
      end

      it "shows the end day" do
        expect(subject).to have_css(".meeting__calendar-day", text: "17")
      end

      it "shows the separator" do
        expect(subject).to have_css(".meeting__calendar-separator")
      end
    end

    context "when meeting spans multiple months" do
      let!(:meeting) { create(:meeting, :published, start_time: Time.new(2020, 10, 15, 10, 0, 0, 0), end_time: Time.new(2020, 11, 17, 12, 0, 0, 0)) }

      it "shows the start month" do
        expect(subject).to have_css(".meeting__calendar-month", text: "Oct")
      end

      it "shows the end month" do
        expect(subject).to have_css(".meeting__calendar-month", text: "Nov")
      end

      it "shows the start day" do
        expect(subject).to have_css(".meeting__calendar-day", text: "15")
      end

      it "shows the end day" do
        expect(subject).to have_css(".meeting__calendar-day", text: "17")
      end

      it "shows month separator" do
        expect(subject).to have_css(".meeting__calendar-separator")
      end
    end

    context "when meeting spans multiple years" do
      let!(:meeting) { create(:meeting, :published, start_time: Time.new(2020, 12, 15, 10, 0, 0, 0), end_time: Time.new(2021, 1, 17, 12, 0, 0, 0)) }

      it "shows the start year" do
        expect(subject).to have_css(".meeting__calendar-year", text: "2020")
      end

      it "shows the end year" do
        expect(subject).to have_css(".meeting__calendar-year", text: "2021")
      end

      it "shows the separator" do
        expect(subject).to have_css(".meeting__calendar-separator")
      end
    end
  end
end
