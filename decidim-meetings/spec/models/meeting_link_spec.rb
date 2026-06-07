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

      context "when meeting in a restricted space with a link" do
        let!(:restricted_process) { create(:participatory_process, :restricted, organization: component.organization) }
        let!(:restricted_component) { create(:component, manifest_name: "meetings", participatory_space: restricted_process) }
        let!(:meeting) { create(:meeting, component: restricted_component) }
        let!(:meeting_link) { create(:meeting_link, meeting:, component:) }

        it "returns an empty array" do
          expect(MeetingLink.find_meetings(component:)).to eq([])
        end
      end

      context "when meeting in a transparent space with a link" do
        let!(:assembly) { create(:assembly, :transparent, organization: component.organization) }
        let!(:transparent_component) { create(:component, manifest_name: "meetings", participatory_space: assembly) }
        let!(:meeting) { create(:meeting, component: transparent_component) }
        let!(:meeting_link) { create(:meeting_link, meeting:, component:) }

        it "returns the meeting" do
          expect(MeetingLink.find_meetings(component:)).to eq([meeting])
        end
      end
    end
  end
end
