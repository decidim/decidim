# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe MeetingLink do
    let(:component) { create(:component) }

    describe "find_meetings" do
      context "when meeting without links" do
        let!(:meeting) { create(:meeting) }

        it "returns an empty array" do
          expect(MeetingLink.find_meetings(component:)).to eq([])
        end
      end

      context "when meeting with a link" do
        let!(:meeting) { create(:meeting) }
        let!(:meeting_link) { create(:meeting_link, meeting:, component:) }

        it "returns the meeting" do
          expect(MeetingLink.find_meetings(component:)).to eq([meeting])
        end
      end

      context "when meeting in a private non transparent space with a link" do
        let!(:private_process) { create(:participatory_process, organization: component.organization, private_space: true) }
        let!(:private_component) { create(:component, manifest_name: "meetings", participatory_space: private_process) }
        let!(:meeting) { create(:meeting, component: private_component) }
        let!(:meeting_link) { create(:meeting_link, meeting:, component:) }

        it "returns an empty array" do
          expect(MeetingLink.find_meetings(component:)).to eq([])
        end
      end

      context "when meeting in a private transparent space with a link" do
        let!(:assembly) { create(:assembly, organization: component.organization, private_space: true, is_transparent: true) }
        let!(:private_component) { create(:component, manifest_name: "meetings", participatory_space: assembly) }
        let!(:meeting) { create(:meeting, component: private_component) }
        let!(:meeting_link) { create(:meeting_link, meeting:, component:) }

        it "returns the meeting" do
          expect(MeetingLink.find_meetings(component:)).to eq([meeting])
        end
      end
    end
  end
end
