# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe ConferenceProgramMeetingsByDay do
    subject { described_class.new(component, day, user) }

    let(:conference) { create(:conference) }

    let(:component) do
      create(:component, manifest_name: :meetings, participatory_space: conference)
    end

    let!(:meeting1) { create(:meeting, :published, component: component, start_time: 1.day.from_now.midday + 90.minutes, end_time: 1.day.from_now.midday + 180.minutes) }
    let!(:meeting2) { create(:meeting, :published, component: component, start_time: 1.day.from_now.midday, end_time: 1.day.from_now.midday + 60.minutes) }
    let!(:meeting3) { create(:meeting, :published, component: component, start_time: 3.days.from_now.midday, end_time: 3.days.from_now.midday + 60.minutes) }
    let!(:day) { meeting1.start_time.to_date }

    describe "query" do
      context "when user is not present" do
        let(:user) { nil }

        it "includes the meetings component" do
          expect(subject.to_a).to eq [
            meeting2,
            meeting1
          ]
        end

        it "excludes the external meetings" do
          expect(subject).not_to include(*meeting3)
        end
      end
    end
  end
end
