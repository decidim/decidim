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

    context "when meeting spans same month and day across different years" do
      let!(:meeting) { create(:meeting, :published, start_time: Time.new(2024, 1, 15, 10, 0, 0, 0), end_time: Time.new(2025, 1, 15, 12, 0, 0, 0)) }

      it "shows the start year" do
        expect(subject).to have_css(".meeting__calendar-year", text: "2024")
      end

      it "shows the end year" do
        expect(subject).to have_css(".meeting__calendar-year", text: "2025")
      end

      it "shows year separator" do
        expect(subject).to have_css(".meeting__calendar-separator")
      end
    end

    describe "#end_year" do
      let!(:meeting) { create(:meeting, :published, start_time: Time.new(2020, 10, 15, 10, 0, 0, 0), end_time: nil) }
      let(:my_cell) { cell("decidim/meetings/dates_and_map", meeting) }

      it "returns nil when end_time is blank" do
        expect(my_cell.end_year).to be_nil
      end

      it "returns formatted year when end_time is present" do
        meeting.update!(end_time: Time.new(2021, 5, 20, 12, 0, 0, 0))
        expect(my_cell.end_year).to eq("2021")
      end
    end

    describe "#same_month?" do
      let!(:meeting) { create(:meeting, :published, start_time: Time.new(2020, 10, 15, 10, 0, 0, 0), end_time: nil) }
      let(:my_cell) { cell("decidim/meetings/dates_and_map", meeting) }

      it "returns true when end_time is blank" do
        expect(my_cell.send(:same_month?)).to be true
      end

      it "returns true when same month" do
        meeting.update!(end_time: Time.new(2020, 10, 20, 12, 0, 0, 0))
        expect(my_cell.send(:same_month?)).to be true
      end

      it "returns false when different months" do
        meeting.update!(end_time: Time.new(2020, 11, 20, 12, 0, 0, 0))
        expect(my_cell.send(:same_month?)).to be false
      end

      it "returns false when same month but different years" do
        meeting.update!(end_time: Time.new(2021, 10, 20, 12, 0, 0, 0))
        expect(my_cell.send(:same_month?)).to be false
      end
    end

    describe "#same_day?" do
      let!(:meeting) { create(:meeting, :published, start_time: Time.new(2020, 10, 15, 10, 0, 0, 0), end_time: nil) }
      let(:my_cell) { cell("decidim/meetings/dates_and_map", meeting) }

      it "returns true when end_time is blank" do
        expect(my_cell.send(:same_day?)).to be true
      end

      it "returns true when same day" do
        meeting.update!(end_time: Time.new(2020, 10, 15, 18, 0, 0, 0))
        expect(my_cell.send(:same_day?)).to be true
      end

      it "returns false when different days" do
        meeting.update!(end_time: Time.new(2020, 10, 20, 12, 0, 0, 0))
        expect(my_cell.send(:same_day?)).to be false
      end

      it "returns false when same day but different years" do
        meeting.update!(end_time: Time.new(2021, 10, 15, 12, 0, 0, 0))
        expect(my_cell.send(:same_day?)).to be false
      end
    end

    describe "#same_year?" do
      let!(:meeting) { create(:meeting, :published, start_time: Time.new(2020, 10, 15, 10, 0, 0, 0), end_time: nil) }
      let(:my_cell) { cell("decidim/meetings/dates_and_map", meeting) }

      it "returns true when end_time is blank" do
        expect(my_cell.send(:same_year?)).to be true
      end

      it "returns true when same year" do
        meeting.update!(end_time: Time.new(2020, 12, 20, 12, 0, 0, 0))
        expect(my_cell.send(:same_year?)).to be true
      end

      it "returns false when different years" do
        meeting.update!(end_time: Time.new(2021, 1, 20, 12, 0, 0, 0))
        expect(my_cell.send(:same_year?)).to be false
      end
    end
  end
end
