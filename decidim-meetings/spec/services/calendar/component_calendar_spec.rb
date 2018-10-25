# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings::Calendar
  describe ComponentCalendar do
    subject { described_class.for(component) }

    let!(:meeting) { create :meeting }
    let!(:component) { meeting.component }
    let!(:another_meeting) { create :meeting, component: component }
    let!(:external_meeting) { create :meeting }

    describe "#to_ical" do
      it "renders the meetings of the given component" do
        expect(subject).to include(meeting.title["en"])
        expect(subject).to include(another_meeting.title["en"])
        expect(subject).not_to include(external_meeting.title["en"])
      end
    end
  end
end
