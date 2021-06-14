# frozen_string_literal: true

require "spec_helper"

describe "Meeting live event", type: :system do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let!(:user) { create :user, :confirmed, organization: organization }
  let(:meeting) { create :meeting, :published, :online, :live, component: component }
  let(:meeting_path) do
    decidim_participatory_process_meetings.meeting_path(
      participatory_process_slug: participatory_process.slug,
      component_id: component.id,
      id: meeting.id
    )
  end
  let(:meeting_live_event_path) do
    decidim_participatory_process_meetings.meeting_live_event_path(
      participatory_process_slug: participatory_process.slug,
      component_id: component.id,
      meeting_id: meeting.id
    )
  end

  before do
    visit meeting_live_event_path
  end

  it "shows the name of the meeting" do
    expect(page).to have_content(meeting.title[I18n.locale.to_s])
  end

  it "shows a close button" do
    expect(page).to have_content("close")

    click_link "close"
    expect(page).to have_current_path meeting_path
  end
end
