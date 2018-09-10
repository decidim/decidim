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

        context "with events" do
          let(:organization) { meeting.organization }
          let(:meeting) { create(:meeting, start_time: 1.week.from_now) }

          it "renders the events" do
            expect(html).to have_css("article.card", count: 1)
          end

          describe "upcoming events" do
            subject { cell.upcoming_events }

            let(:cell) { described_class.new(nil, context: { controller: controller }) }
            let!(:past_meeting) do
              create(:meeting, start_time: 1.week.ago, component: meeting.component)
            end

            it { is_expected.not_to include(past_meeting) }
            it { is_expected.to include(meeting) }
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
