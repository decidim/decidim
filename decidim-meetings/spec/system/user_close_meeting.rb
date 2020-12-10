# frozen_string_literal: true

require "spec_helper"
require "decidim/proposals/test/capybara_proposals_picker"

describe "User edit meeting", type: :system do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let!(:user) { create :user, :confirmed, organization: participatory_process.organization }
  let!(:another_user) { create :user, :confirmed, organization: participatory_process.organization }
  let!(:meeting) do
    create(:meeting,
           :past,
           title: { en: "Meeting title with #hashtag" },
           description: { en: "Meeting description" },
           author: user,
           component: component)
  end
  let(:component) do
    create(:meeting_component,
           :with_creation_enabled,
           participatory_space: participatory_process)
  end

  before do
    switch_to_host user.organization.host
  end

  describe "closing my own meeting" do
    let(:closing_report) { "The meeting went pretty well, yep." }

    before do
      login_as user, scope: :user
    end

    it "updates the related attributes" do
      visit_component

      click_link translated(meeting.title)
      click_link "Close meeting"

      expect(page).to have_content "CLOSE MEETING"

      within "form.edit_close_meeting" do
        fill_in :close_meeting_closing_report, with: closing_report

        click_button "Close meeting"
      end

      expect(page).to have_content(closing_report)
      expect(page).not_to have_content "Close meeting"
      expect(page).not_to have_content "ATTENDEES COUNT"
      expect(page).not_to have_content "ATTENDING ORGANIZATIONS"
      expect(meeting.reload.closed_at).not_to be nil
    end
  end

  describe "closing someone else's meeting" do
    before do
      login_as another_user, scope: :user
    end

    it "doesn't show the button" do
      visit_component

      click_link translated(meeting.title)
      expect(page).to have_no_content("Close meeting")
    end
  end
end
