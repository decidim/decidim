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

        describe "jitsi configuration" do
          let(:iframe_config) { parse_iframe_config(page.find("iframe")) }

          it "reads the user info" do
            expect(iframe_config["userInfo.email"]).to eq(user.email)
            expect(iframe_config["userInfo.displayName"]).to eq(user.name)
          end

          it "has the right interface settings" do
            expect(iframe_config["interfaceConfig.SHOW_JITSI_WATERMARK"]).to eq(false)
            expect(iframe_config["interfaceConfig.HIDE_INVITE_MORE_HEADER"]).to eq(true)
            %w(
              camera
              chat
              closedcaptions
              desktop
              download
              etherpad
              feedback
              filmstrip
              fodeviceselection
              fullscreen
              hangup
              help
              microphone
              profile
              raisehand
              shortcuts
              tileview
              videobackgroundblur
              videoquality
            ).each { |button| expect(iframe_config["interfaceConfig.TOOLBAR_BUTTONS"]).to include(button) }
          end

          it "has the right config settings" do
            expect(iframe_config["config.disableInviteFunctions"]).to eq(true)
            expect(iframe_config["config.disableSimulcast"]).to eq(false)
            expect(iframe_config["config.startWithAudioMuted"]).to eq(false)
            expect(iframe_config["config.startWithVideoMuted"]).to eq(false)
          end
        end
      end
    end
  end

  def parse_iframe_config(iframe)
    src = Rack::Utils.parse_nested_query(iframe[:src])
    src.transform_values { |v| JSON.parse(v) }
  end
end
