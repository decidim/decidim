# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings::Calendar
  describe MeetingCalendar do
    subject { described_class.for(meeting) }

    let!(:meeting) { create(:meeting, title: Decidim::Faker::Localized.localized { "<script>alert(\"foo\")</script> #{generate(:title)}" }) }
    let!(:another_meeting) { create(:meeting, title: Decidim::Faker::Localized.localized { "<script>alert(\"bar\")</script> #{generate(:title)}" }) }

    describe "#calendar" do
      it "renders a full calendar" do
        expect(subject).to include "BEGIN:VCALENDAR"
        expect(subject).to include "END:VCALENDAR"
        expect(subject).to include "BEGIN:VEVENT"
        expect(subject).to include "END:VEVENT"
      end

      it "renders a single meeting" do
        expect(subject).to include(meeting.title["en"])
        expect(subject).not_to include(another_meeting.title["en"])
        expect(subject).to include("BEGIN:VEVENT").once
      end
    end

    describe "#events" do
      subject { described_class.new(meeting).events }

      it "renders a single event" do
        expect(subject).not_to include "BEGIN:VCALENDAR"
        expect(subject).not_to include "END:VCALENDAR"
        expect(subject).to include("BEGIN:VEVENT").once
        expect(subject).to include("END:VEVENT").once
      end

      it "renders the meeting" do
        expect(subject).to include(meeting.title["en"])
        expect(subject).not_to include(another_meeting.title["en"])
      end
    end
  end
end
