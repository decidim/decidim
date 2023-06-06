# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings::Calendar
  describe ComponentCalendar do
    subject { described_class.for(component) }

    let(:title) { Decidim::Faker::Localized.localized { "<script>alert(\"fooo\")</script> #{generate(:title)}" } }
    let!(:meeting) { create(:meeting, :published, title:) }
    let!(:component) { meeting.component }
    let!(:another_meeting) { create(:meeting, :published, component:, title: Decidim::Faker::Localized.localized { generate(:title) }) }
    let!(:external_meeting) { create(:meeting, title: Decidim::Faker::Localized.localized { generate(:title) }) }
    let!(:unpublished_meeting) { create(:meeting, component:, title: Decidim::Faker::Localized.localized { generate(:title) }) }
    let!(:withdrawn_meeting) { create(:meeting, :published, :withdrawn, title: Decidim::Faker::Localized.localized { generate(:title) }) }

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
        expect(subject).not_to include(unpublished_meeting.title["en"])
        expect(subject).not_to include(withdrawn_meeting.title["en"])
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
        expect(subject).not_to include(unpublished_meeting.title["en"])
        expect(subject).not_to include(withdrawn_meeting.title["en"])
      end
    end

    describe "#filters" do
      subject { described_class.for(component, filters) }

      let!(:filters) { { "with_any_origin" => ["", "official"], "with_any_type" => ["", "online"] } }

      context "when no meetings returned" do
        let!(:online_meeting) { create(:meeting, :published, :not_official, :online, component:, title:) }

        it "returns a nil value" do
          expect(subject).to be_nil
        end
      end

      context "when having meetings returned" do
        let!(:online_meeting) { create(:meeting, :published, :official, :online, component:, title: Decidim::Faker::Localized.localized { generate(:title) }) }

        it "renders the meetings of the given component based on filters" do
          expect(subject).to include(online_meeting.title["en"])
          expect(subject).not_to include(meeting.title["en"])
          expect(subject).not_to include(another_meeting.title["en"])
          expect(subject).not_to include(external_meeting.title["en"])
          expect(subject).not_to include(unpublished_meeting.title["en"])
          expect(subject).not_to include(withdrawn_meeting.title["en"])
        end
      end
    end
  end
end
