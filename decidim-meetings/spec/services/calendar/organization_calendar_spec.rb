# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings::Calendar
  describe OrganizationCalendar do
    subject { described_class.for(organization) }

    let!(:meeting) { create :meeting, :published }
    let!(:component) { meeting.component }
    let!(:component2) { create :meeting_component, participatory_space: component.participatory_space }
    let!(:organization) { component.organization }
    let!(:another_meeting) { create :meeting, :published, component: component2 }
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
      subject { described_class.new(organization).events }

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

    describe "#filters" do
      subject { described_class.for(organization, filters) }

      let(:online_meeting) { create :meeting, :official, :online, component: }
      let(:online_meeting2) { create :meeting, :not_official, :online, component: component2 }
      let!(:withdrawn_meeting) { create :meeting, :published, :withdrawn, component: component2 }
      let!(:filters) { { "with_any_origin" => ["", "official"], "with_any_type" => ["", "online"] } }

      context "when no meetings returned" do
        before do
          online_meeting.published_at = nil
          online_meeting2.published_at = nil
          online_meeting.save!
          online_meeting2.save!
        end

        it "returns a nil value" do
          expect(subject).to be_nil
        end
      end

      context "when having meetings returned" do
        before do
          online_meeting.published_at = Time.current
          online_meeting2.published_at = Time.current
          online_meeting.save!
          online_meeting2.save!
        end

        it "renders the meetings of the given component based on filters" do
          expect(subject).to include(online_meeting.title["en"])
          expect(subject).not_to include(online_meeting2.title["en"])
          expect(subject).not_to include(meeting.title["en"])
          expect(subject).not_to include(another_meeting.title["en"])
          expect(subject).not_to include(external_meeting.title["en"])
          expect(subject).not_to include(withdrawn_meeting.title["en"])
        end
      end
    end
  end
end
