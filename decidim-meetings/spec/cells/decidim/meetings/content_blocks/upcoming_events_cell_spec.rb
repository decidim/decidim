# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    module ContentBlocks
      describe UpcomingEventsCell, type: :cell do
        controller Decidim::Meetings::Directory::MeetingsController

        let(:html) { cell("decidim/meetings/content_blocks/upcoming_events").call }
        let(:organization) { create(:organization) }

        before do
          expect(controller).to receive(:current_organization).and_return(organization)
        end

        context "when rendering" do
          let(:organization) { meeting.organization }
          let(:meeting) { create(:meeting, start_time: 1.week.from_now) }
          let!(:past_meeting) do
            create(:meeting, start_time: 1.week.ago, component: meeting.component)
          end

          it "renders the events" do
            expect(html).to have_css("article.card", count: 1)
          end
        end

        context "with no events" do
          it "renders nothing" do
            expect(html).to have_no_css(".upcoming-events")
          end
        end
      end
    end
  end
end
