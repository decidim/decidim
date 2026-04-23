# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe MeetingLCell, type: :cell do
    controller Decidim::Meetings::MeetingsController
    include Decidim::SanitizeHelper

    subject { my_cell.call }

    let!(:meeting) { create(:meeting, :published, start_time: Time.new(2020, 10, 15, 10, 4, 5, 0)) }
    let(:my_cell) { cell("decidim/meetings/meeting_l", meeting) }

    context "when rendering" do
      it "renders the card" do
        expect(subject).to have_css("#meetings__meeting_#{meeting.id}.card__calendar-list__reset")
      end

      it "shows the start time's month" do
        expect(subject).to have_css(".card__calendar-month", text: "Oct")
      end

      it "shows the start time's day" do
        expect(subject).to have_css(".card__calendar-day", text: "15")
      end

      it "shows the start time's year" do
        expect(subject).to have_css(".card__calendar-year", text: "2020")
      end

      it "does not show separator" do
        expect(subject).to have_no_css(".card__calendar-separator")
      end
    end

    context "when meeting spans multiple days in the same month" do
      let!(:meeting) { create(:meeting, :published, start_time: Time.new(2020, 10, 15, 10, 0, 0, 0), end_time: Time.new(2020, 10, 17, 12, 0, 0, 0)) }

      it "shows the start day" do
        expect(subject).to have_css(".card__calendar-day", text: "15")
      end

      it "shows the end day" do
        expect(subject).to have_css(".card__calendar-day", text: "17")
      end

      it "shows the separator" do
        expect(subject).to have_css(".card__calendar-separator")
      end

      it "does not show month separator" do
        expect(subject).to have_css(".card__calendar-month", text: "October")
      end
    end

    context "when meeting spans multiple months" do
      let!(:meeting) { create(:meeting, :published, start_time: Time.new(2020, 10, 15, 10, 0, 0, 0), end_time: Time.new(2020, 11, 17, 12, 0, 0, 0)) }

      it "shows the start month" do
        expect(subject).to have_css(".card__calendar-month", text: "Oct")
      end

      it "shows the end month" do
        expect(subject).to have_css(".card__calendar-month", text: "Nov")
      end

      it "shows the start day" do
        expect(subject).to have_css(".card__calendar-day", text: "15")
      end

      it "shows the end day" do
        expect(subject).to have_css(".card__calendar-day", text: "17")
      end

      it "shows month separator" do
        expect(subject).to have_css(".card__calendar-separator")
      end
    end

    context "when meeting has no end time" do
      let!(:meeting) { create(:meeting, :published, start_time: Time.new(2020, 10, 15, 10, 0, 0, 0), end_time: nil) }

      it "shows the start time's month" do
        expect(subject).to have_css(".card__calendar-month", text: "October")
      end

      it "shows the start time's day" do
        expect(subject).to have_css(".card__calendar-day", text: "15")
      end

      it "does not show separator" do
        expect(subject).to have_no_css(".meeting__calendar-separator")
      end
    end

    context "when meeting spans multiple years" do
      let!(:meeting) { create(:meeting, :published, start_time: Time.new(2020, 12, 15, 10, 0, 0, 0), end_time: Time.new(2021, 1, 17, 12, 0, 0, 0)) }

      it "shows the start year" do
        expect(subject).to have_css(".card__calendar-year", text: "2020")
      end

      it "shows the end year" do
        expect(subject).to have_css(".card__calendar-year", text: "2021")
      end

      it "shows the separator" do
        expect(subject).to have_css(".card__calendar-separator")
      end
    end

    context "when title contains special html entities" do
      let!(:original_title) { meeting.title["en"] }

      before do
        meeting.update!(title: { en: "<strong>#{original_title}</strong> &'<" })
        meeting.reload
      end

      it "escapes them correctly" do
        title = decidim_html_escape(original_title).gsub("&quot;", '"')
        expect(subject.to_s).to include("&lt;strong&gt;#{title}&lt;/strong&gt; &amp;'&lt;")
      end
    end

    context "when show_space is false" do
      let(:my_cell) { cell("decidim/meetings/meeting_l", meeting, context: { show_space: false }) }

      it "does not show the participatory space" do
        expect(subject).to have_no_content(decidim_escape_translated(meeting.component.participatory_space.title))
      end
    end

    context "when show_space is true" do
      let(:my_cell) { cell("decidim/meetings/meeting_l", meeting, context: { show_space: true }) }

      it "shows the participatory space" do
        expect(subject).to have_content(translated_attribute(meeting.component.participatory_space.title))
        expect(subject.to_s).to include(decidim_escape_translated(meeting.component.participatory_space.title).gsub("&quot;", "\""))
      end
    end

    describe "#same_month?" do
      let!(:meeting) { create(:meeting, :published, start_time: Time.new(2020, 10, 15, 10, 0, 0, 0), end_time: nil) }
      let(:my_cell) { cell("decidim/meetings/meeting_l", meeting) }

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
    end

    describe "#same_day?" do
      let!(:meeting) { create(:meeting, :published, start_time: Time.new(2020, 10, 15, 10, 0, 0, 0), end_time: nil) }
      let(:my_cell) { cell("decidim/meetings/meeting_l", meeting) }

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
    end

    describe "#same_year?" do
      let!(:meeting) { create(:meeting, :published, start_time: Time.new(2020, 10, 15, 10, 0, 0, 0), end_time: nil) }
      let(:my_cell) { cell("decidim/meetings/meeting_l", meeting) }

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
