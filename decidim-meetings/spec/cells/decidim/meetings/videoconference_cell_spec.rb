# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe VideoconferenceCell, type: :cell do
    controller Decidim::Meetings::MeetingsController

    let!(:meeting) { create(:meeting, reference: "Meeting-Reference_2020#!") }
    let(:model) { meeting }
    let(:the_cell) { cell("decidim/meetings/videoconference", model, context: { current_user: user }) }
    let(:user) { create(:user) }

    context "when rendering" do
      subject { the_cell.call }

      let(:html) { subject }

      context "when the videoconference is not visible" do
        before do
          expect(the_cell).to receive(:visible?).and_return(false)
        end

        it "does not render the videoconference div" do
          expect(html).to have_no_selector("#jitsi-embedded-meeting")
        end

        it "does not render the join button" do
          expect(html).to have_no_button("Join videoconference")
        end

        it "renders a warning message" do
          expect(html).to have_content("not available")
        end
      end

      context "when the videoconference is visible" do
        before do
          expect(the_cell).to receive(:visible?).at_least(:once).and_return(true)
        end

        let(:attributes) { html.find("#jitsi-embedded-meeting").native.attributes }

        it "renders the videoconference div" do
          expect(html).to have_selector("#jitsi-embedded-meeting")
          expect(attributes["data-room-name"].value).to eq(the_cell.room_name)
          expect(attributes["data-user-email"].value).to eq(user.email)
          expect(attributes["data-user-display-name"].value).to eq(user.name)
          expect(attributes["data-user-role"].value).to eq("participant")
        end

        it "renders the join button" do
          expect(html).to have_button("Join videoconference")
        end

        it "does not render the warning message" do
          expect(html).to have_no_content("not available")
        end
      end
    end

    describe "#room_name" do
      before do
        expect(the_cell).to receive(:token).and_return("token")
      end

      it "generates a room name with the meeting reference and a random token" do
        expect(the_cell.room_name).to eq("MeetingReference2020token")
      end

      it "generates a room name with only alphanumeric characters" do
        meeting.update!(reference: "I#H4v€-unwanted_cha%ra!`cht?ers-")
        expect(the_cell.room_name).to match(/\w+/)
        expect(the_cell.room_name).not_to match(/_/)
      end
    end
  end
end
