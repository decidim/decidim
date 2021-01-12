# frozen_string_literal: true

require "spec_helper"

describe "Videoconference", type: :system do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let!(:meeting) { create :meeting, type_of_meeting: "online", embedded_videoconference: true, component: component }
  let!(:user) { create :user, :confirmed, organization: organization }

  def visit_meeting
    visit resource_locator(meeting).path
  end

  before do
    login_as user, scope: :user
  end

  context "when meeting has a videoconference" do
    context "when meeting is not open" do
      it "shows a warning message" do
        visit_meeting

        expect(page).to have_content("not available")
        expect(page).not_to have_button("Join videoconference")
      end
    end

    context "when meeting is open" do
      let!(:meeting) { create :meeting, type_of_meeting: "online", embedded_videoconference: true, start_time: 1.day.ago, end_time: 1.day.from_now, component: component }

      it "shows a warning message" do
        visit_meeting

        expect(page).not_to have_content("not available")
        expect(page).to have_button("Join videoconference")
      end

      context "when clicking on join videoconference" do
        before do
          visit_meeting

          click_on "Join videoconference"
        end

        it "loads the iframe" do
          within "#jitsi-embedded-meeting" do
            expect(page).to have_selector("iframe")
          end
        end
      end
    end
  end
end
