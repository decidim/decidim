# frozen_string_literal: true

require "spec_helper"

describe "Meeting live event" do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let!(:user) { create(:user, :confirmed, organization:) }
  let(:meeting) { create(:meeting, :published, :online, :live, component:) }
  let(:meeting_path) do
    decidim_participatory_process_meetings.meeting_path(
      participatory_process_slug: participatory_process.slug,
      component_id: component.id,
      id: meeting.id,
      locale: I18n.locale
    )
  end
  let(:meeting_live_event_path) do
    decidim_participatory_process_meetings.meeting_live_event_path(
      participatory_process_slug: participatory_process.slug,
      component_id: component.id,
      meeting_id: meeting.id,
      locale: I18n.locale
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

    click_on "close"
    expect(page).to have_current_path meeting_path
  end

  context "with essential cookies only" do
    before do
      visit decidim.root_path
      data_consent("essential")
    end

    it "tells that you need to enable cookies" do
      visit meeting_live_event_path
      expect(page).to have_no_selector("iframe")
      expect(page).to have_content("You need to enable all cookies in order to see this content")
    end

    it "can enable all cookies" do
      visit meeting_live_event_path
      click_on "Change cookie settings"
      click_on "Accept all"
      expect(page).to have_css("iframe")
    end
  end

  context "when user is logged and session is about to timeout" do
    before do
      allow(Decidim.config).to receive(:expire_session_after).and_return(2.minutes)
      allow(Decidim.config).to receive(:session_timeout_interval).and_return(1.second)
      switch_to_host(organization.host)
      visit decidim.root_path
      data_consent("essential")
      login_as user, scope: :user
      visit meeting_live_event_path
    end

    context "when meeting is live" do
      let(:meeting) { create(:meeting, :published, :online, :embed_in_meeting_page_iframe_embed_type, component:, start_time: 1.minute.ago, end_time:) }
      let(:end_time) { 1.hour.from_now }

      it "does not timeout user" do
        travel 5.minutes
        expect(page).to have_css("[aria-label='User account: #{user.name}']")
        expect(page).to have_no_content("If you continue being inactive", wait: 4)
        expect(page).to have_no_content("You were inactive for too long")
      end

      context "and ends soon" do
        let(:end_time) { 15.seconds.from_now }

        it "logs user out" do
          travel 1.minute
          expect(page).to have_content("If you continue being inactive", wait: 30)
          allow(Time).to receive(:current).and_return(1.minute.from_now)
          expect(page).to have_content("You are not allowed to view this meeting")
        end
      end
    end
  end
end
