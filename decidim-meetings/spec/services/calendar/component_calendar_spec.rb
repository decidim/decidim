# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings::Calendar
  describe ComponentCalendar do
    subject { described_class.for(component) }

    let!(:meeting) { create :meeting }
    let!(:component) { meeting.component }
    let!(:another_meeting) { create :meeting, component: component }
    let!(:external_meeting) { create :meeting }

    describe "#calendar" do
      it "renders a full calendar" do
        expect(subject).to include "BEGIN:VCALENDAR"
        expect(subject).to include "END:VCALENDAR"
        expect(subject).to include "BEGIN:VEVENT"
        expect(subject).to include "END:VEVENT"
      end

      it "renders the meetings of the given component" do
        expect(subject).to include(meeting.title["en"])
        expect(subject).to include(another_meeting.title["en"])
        expect(subject).not_to include(external_meeting.title["en"])
      end
    end

    describe "#events" do
      subject { described_class.new(component).events }

      it "renders a list of events" do
        expect(subject).not_to include "BEGIN:VCALENDAR"
        expect(subject).not_to include "END:VCALENDAR"
        expect(subject).to include "BEGIN:VEVENT"
        expect(subject).to include "END:VEVENT"
      end

      it "renders the meetings of the given component" do
        expect(subject).to include(meeting.title["en"])
        expect(subject).to include(another_meeting.title["en"])
        expect(subject).not_to include(external_meeting.title["en"])
      end
    end
  end
end
