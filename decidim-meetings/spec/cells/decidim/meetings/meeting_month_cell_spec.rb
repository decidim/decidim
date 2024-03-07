# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe MeetingMonthCell, type: :cell do
      subject { my_cell.call }

      let!(:collection) { create_list(:meeting, 5, :published, start_time: Time.zone.local(2021, 5, 15)) }
      let(:my_cell) { cell("decidim/meetings/meeting_month", collection, start_date:) }

      context "when the date is the same month" do
        let(:start_date) { Time.zone.local(2021, 5, 1) }

        it "renders the date of the meetings" do
          expect(subject).to have_css(".is-past-event")
        end

        it "renders the month" do
          expect(subject).to have_css("time", count: 31)
        end
      end

      context "when the date is a month without meetings" do
        let(:start_date) { Time.zone.local(2021, 4, 1) }

        it "does not render any meeting" do
          expect(subject).to have_no_css(".is-past-event")
        end

        it "does not render the month" do
          expect(subject).to have_css("time", count: 0)
        end
      end
    end
  end
end
