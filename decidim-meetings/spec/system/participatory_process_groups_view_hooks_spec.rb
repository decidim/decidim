# frozen_string_literal: true

require "spec_helper"

describe "Meetings in process group home", type: :system do
  include_context "with a component"
  let(:manifest_name) { "meetings" }
  let(:meetings_count) { 5 }

  let!(:participatory_process_group) do
    create(
      :participatory_process_group,
      participatory_processes: [participatory_process],
      organization: organization,
      name: { en: "Name", ca: "Nom", es: "Nombre" }
    )
  end

  context "when there are only past meetings" do
    let!(:past_meetings) do
      create_list(:meeting, meetings_count, :past, component: component)
    end

    it "shows the last three past meetings" do
      visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group)
      expect(page).to have_css(".past_meetings .card--meeting", count: 3)

      past_meetings.sort_by { |m| [m.end_time, m.start_time] }.last(3).each do |meeting|
        expect(page).to have_content(/#{translated(meeting.title)}/i)
      end
    end
  end

  context "when there are only upcoming meetings" do
    let!(:upcoming_meetings) do
      create_list(:meeting, meetings_count, :upcoming, component: component)
    end

    it "shows the first three upcoming meetings" do
      visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group)
      expect(page).to have_css(".upcoming_meetings .card--meeting", count: 3)

      upcoming_meetings.sort_by { |m| [m.start_time, m.end_time] }.first(3).each do |meeting|
        expect(page).to have_content(/#{translated(meeting.title)}/i)
      end
    end
  end

  context "when there are past and upcoming meetings" do
    let!(:past_meetings) do
      create_list(:meeting, meetings_count, :past, component: component)
    end

    let!(:upcoming_meetings) do
      create_list(:meeting, meetings_count, :upcoming, component: component)
    end

    it "only shows the first three upcoming meetings" do
      visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group)
      expect(page).to have_css(".upcoming_meetings .card--meeting", count: 3)
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
