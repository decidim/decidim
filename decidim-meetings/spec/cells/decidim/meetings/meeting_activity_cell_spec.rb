# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe MeetingActivityCell, type: :cell do
      controller Decidim::LastActivitiesController

      let!(:meeting) { create(:meeting, :published) }
      let(:action) { :publish }
      let(:action_log) do
        create(
          :action_log,
          action:,
          resource: meeting,
          organization: meeting.organization,
          component: meeting.component,
          participatory_space: meeting.participatory_space
        )
      end

      context "when rendering" do
        it "renders the card" do
          html = cell("decidim/meetings/meeting_activity", action_log).call
          expect(html).to have_css("#action-#{action_log.id}[data-activity]")
        end

        context "when action is update" do
          let(:action) { :update }

          it "renders the correct title" do
            html = cell("decidim/meetings/meeting_activity", action_log).call
            expect(html).to have_css("#action-#{action_log.id}[data-activity]")
            expect(html).to have_content("Meeting updated")
          end
        end

        context "when action is create" do
          let(:action) { :create }

          it "renders the correct title" do
            html = cell("decidim/meetings/meeting_activity", action_log).call
            expect(html).to have_css("#action-#{action_log.id}[data-activity]")
            expect(html).to have_content("New meeting")
          end
        end

        context "when action is publish" do
          it "renders the correct title" do
            html = cell("decidim/meetings/meeting_activity", action_log).call
            expect(html).to have_css("#action-#{action_log.id}[data-activity]")
            expect(html).to have_content("New meeting")
          end
        end
      end
    end
  end
end
