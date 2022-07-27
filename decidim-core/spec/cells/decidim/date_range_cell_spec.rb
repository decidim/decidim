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
      expect(subject).to have_css(".extra__date-container")
    end
  end

  context "when start and end time are on the same date" do
    let(:end_time) { end_time_same_date }

    it "renders only one date and time" do
      has_date 1
      has_time 1
    end
  end

  context "when start and end time are on different dates" do
    let(:end_time) { end_time_different_date }

    it "renders the two dates and times" do
      has_date 2
      has_time 2
    end
  end

  context "when start and end time are on different years" do
    let(:end_time) { end_time_different_year }

    it "renders the two dates and times" do
      has_date 2
      has_time 2
    end

    it "renders two year elements" do
      expect(subject).to have_content(start_time.year.to_s)
      expect(subject).to have_content(end_time.year.to_s)
    end
  end

  context "when start time is not the current year" do
    let(:start_time) { start_time_past_year }
    let(:end_time) { end_time_past_year }

    it "renders two year elements" do
      expect(subject).to have_content(start_time.year.to_s)
      expect(subject).to have_content(end_time.year.to_s)
    end
  end

  def has_time(count)
    expect(subject).to have_css(".extra__time", count:)
  end

  def has_date(count)
    expect(subject).to have_css(".extra__date", count:)
  end

  def has_month(count)
    expect(subject).to have_css(".extra__month", count:)
  end
end
