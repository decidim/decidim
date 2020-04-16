# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings::Calendar
  describe MeetingToEvent do
    subject { described_class.new(meeting) }

    let(:meeting) { create :meeting }
    let(:event) { subject.event }

    describe "#event" do
      it "converts the meeting to an event" do
        expect(event.summary).to eq(translated(meeting.title))
        expect(event.description).to eq(strip_tags(translated(meeting.description)))
        expect(event.dtstart.value.to_i).to eq(Icalendar::Values::DateTime.new(meeting.start_time).value.to_i)
        expect(event.dtend.value.to_i).to eq(Icalendar::Values::DateTime.new(meeting.end_time).value.to_i)
        expect(event.geo).to eq([meeting.latitude, meeting.longitude])
      end
    end

    describe "#to_ical" do
      it "delegates the work to the event" do
        expect(event).to receive(:to_ical)
        subject.to_ical
      end

      it "dates are in UTC" do
        expect(subject.to_ical).to include(event.dtstart.strftime("DTSTART:%Y%m%dT%H%M%SZ"))
        expect(subject.to_ical).to include(event.dtend.strftime("DTEND:%Y%m%dT%H%M%SZ"))
      end
    end
  end
end
