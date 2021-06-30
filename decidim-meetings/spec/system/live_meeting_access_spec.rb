# frozen_string_literal: true

require "spec_helper"

describe "Meeting live event access", type: :system do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let!(:user) { create :user, :confirmed, organization: organization }
  let(:meeting_live_event_path) do
    decidim_participatory_process_meetings.meeting_live_event_path(
      participatory_process_slug: participatory_process.slug,
      component_id: component.id,
      meeting_id: meeting.id
    )
  end

  def visit_meeting
    visit resource_locator(meeting).path
  end

  context "when online meeting is live" do
    let(:meeting) { create :meeting, :published, :online, :live, component: component }

    it "shows the link to the live meeting streaming" do
      visit_meeting

      expect(page).to have_content("This meeting is happening right now")
    end

    context "when the meeting is configured to not embed the iframe" do
      let(:meeting) { create :meeting, :published, :online, :live, :embeddable, component: component }

      it "shows the link to the live meeting streaming" do
        visit_meeting

        new_window = window_opened_by { click_link "Join meeting" }

        within_window new_window do
          expect(page).to have_current_path(meeting_live_event_path)
        end
      end
    end

    context "when the meeting is configured to not embed the iframe and is not embeddable" do
      let(:meeting) { create :meeting, :published, :online, :live, component: component }

      it "shows the link to the external streaming service" do
        visit_meeting

        # Join the meeting displays a warning to users because
        # is redirecting to a different domain
        click_link "Join meeting"

        expect(page).to have_content("Open external link")
      end
    end

    context "when the meeting is configured to show the iframe embedded" do
      let(:meeting) { create :meeting, :published, :show_embedded_iframe, :online, :embeddable, :live, component: component }

      it "shows the meeting link embedded" do
        visit_meeting

        expect(page).to have_css("iframe")
      end
    end
  end

  context "when online meeting is not live" do
    let(:meeting) { create :meeting, :published, :online, :past, component: component }

    it "doesn't show the link to the live meeting streaming" do
      visit_meeting

      expect(page).to have_no_content("This meeting is happening right now")
    end
  end
end
