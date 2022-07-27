# frozen_string_literal: true

require "spec_helper"

describe "Meetings in process home", type: :system do
  include_context "with a component"
  let(:manifest_name) { "meetings" }
  let(:meetings_count) { 5 }

  context "when there are only past meetings" do
    let!(:moderated_meeting) { create(:meeting, :moderated, :published, :past, component:, end_time: 5.hours.ago) }
    let!(:past_meetings) do
      create_list(:meeting, meetings_count, :published, :past, component:)
    end

    it "shows the last three past meetings" do
      visit resource_locator(participatory_process).path
      expect(page).to have_css(".past_meetings .card--list__item", count: 3)

      expect(page).not_to have_content(/#{translated(moderated_meeting.title)}/i)

      past_meetings.sort_by { |m| [m.end_time, m.start_time] }.last(3).each do |meeting|
        expect(page).to have_content(/#{translated(meeting.title)}/i)
      end
    end
  end

  context "when there are only upcoming meetings" do
    let!(:upcoming_meetings) do
      create_list(:meeting, meetings_count, :published, :upcoming, component:)
    end
    let!(:moderated_meeting) { create(:meeting, :moderated, :published, :upcoming, component:) }

    it "shows the first three upcoming meetings" do
      visit resource_locator(participatory_process).path
      expect(page).to have_css(".upcoming_meetings .card--list__item", count: 3)

      expect(page).not_to have_content(/#{translated(moderated_meeting.title)}/i)

      upcoming_meetings.sort_by { |m| [m.start_time, m.end_time] }.first(3).each do |meeting|
        expect(page).to have_content(/#{translated(meeting.title)}/i)
      end
    end
  end

  context "when there are past and upcoming meetings" do
    let!(:past_meetings) do
      create_list(:meeting, meetings_count, :published, :past, component:)
    end

    let!(:upcoming_meetings) do
      create_list(:meeting, meetings_count, :published, :upcoming, component:)
    end

    it "only shows the first three upcoming meetings" do
      visit resource_locator(participatory_process).path
      expect(page).to have_css(".upcoming_meetings .card--list__item", count: 3)
      expect(page).not_to have_css(".past_meetings")

      past_meetings.each do |meeting|
        expect(page).not_to have_content(/#{translated(meeting.title)}/i)
      end

      upcoming_meetings.sort_by { |m| [m.start_time, m.end_time] }.first(3).each do |meeting|
        expect(page).to have_content(/#{translated(meeting.title)}/i)
      end
    end
  end
end
