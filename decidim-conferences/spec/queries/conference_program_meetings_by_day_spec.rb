# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe ConferenceProgramMeetingsByDay do
    subject { described_class.new(component, day, user) }

    let(:conference) { create(:conference) }

    let(:component) do
      create(:component, manifest_name: :meetings, participatory_space: conference)
    end

    let!(:meeting_1) { create(:meeting, component: component, start_time: 1.day.from_now.midday + 90.minutes, end_time: 1.day.from_now.midday + 180.minutes) }
    let!(:meeting_2) { create(:meeting, component: component, start_time: 1.day.from_now.midday, end_time: 1.day.from_now.midday + 60.minutes) }
    let!(:meeting_3) { create(:meeting, component: component, start_time: 3.days.from_now.midday, end_time: 3.days.from_now.midday + 60.minutes) }
    let!(:day) { meeting_1.start_time.to_date }

    describe "query" do
      context "when user is not present" do
        let(:user) { nil }

        it "includes the meetings component" do
          expect(subject.to_a).to eq [
            meeting_2,
            meeting_1
          ]
        end

        it "excludes the external meetings" do
          expect(subject).not_to include(*meeting_3)
        end
      end
    end
  end
end
