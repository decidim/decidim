# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    module ContentBlocks
      describe HighlightedMeetingsCell, type: :cell do
        controller Decidim::Meetings::Directory::MeetingsController

        let(:content_block) { create :content_block, organization:, manifest_name: :upcoming_meetings, scope_name: :homepage }
        let(:organization) { create(:organization) }
        let(:current_user) { create :user, :confirmed, organization: }
        let(:html) { cell("decidim/meetings/content_blocks/highlighted_meetings", content_block).call }

        context "with meetings" do
          let(:organization) { meeting.organization }
          let(:meeting) { create(:meeting, :published, start_time: 1.week.from_now) }

          it "renders the meetings" do
            expect(html).to have_css(".card__list", count: 1)
          end

          context "with upcoming meetings" do
            let(:meetings_ids) { html.find_all("a.card__list").map { |node| node[:id] } }
            let!(:past_meeting) do
              create(:meeting, :published, start_time: 1.week.ago, component: meeting.component)
            end
            let!(:second_meeting) do
              create(:meeting, :published, start_time: meeting.start_time.advance(weeks: 1), component: meeting.component)
            end
            let!(:moderated_meeting) do
              create(:meeting, :moderated, :published, start_time: meeting.start_time.advance(weeks: 1), component: meeting.component)
            end
            let!(:unpublished_meeting) do
              create(:meeting, start_time: 2.weeks.from_now, component: meeting.component)
            end

            it { expect(html).to have_content("Upcoming meetings") }
            it { expect(html).to have_no_content("Past meetings") }
            it { expect(meetings_ids).not_to include(item_id(moderated_meeting)) }
            it { expect(meetings_ids).not_to include(item_id(past_meeting)) }
            it { expect(meetings_ids).to include(item_id(meeting)) }
            it { expect(meetings_ids).to include(item_id(second_meeting)) }
            it { expect(meetings_ids).not_to include(item_id(unpublished_meeting)) }

            it "orders them correctly" do
              expect(meetings_ids.length).to eq(2)
              expect(meetings_ids.first).to eq(item_id(meeting))
              expect(meetings_ids.last).to eq(item_id(second_meeting))
            end

            context "with upcoming private meetings" do
              let!(:meeting) do
                create(:meeting, :published, start_time: 1.week.from_now, private_meeting: true, transparent: false)
              end
              let!(:second_meeting) do
                create(:meeting, :published, start_time: meeting.start_time.advance(weeks: 1), component: meeting.component, private_meeting: true, transparent: false)
              end

              it "renders past meetings" do
                expect(html).to have_no_content("Upcoming meetings")
                expect(html).to have_content("Past meetings")
                expect(meetings_ids).not_to include(item_id(meeting))
                expect(meetings_ids).not_to include(item_id(second_meeting))
                expect(meetings_ids).to include(item_id(past_meeting))
                expect(meetings_ids.length).to eq(1)
              end
            end

            context "with upcoming private meetings but invited user" do
              let!(:meeting) do
                create(:meeting, :published, start_time: 1.week.from_now, private_meeting: true, transparent: false)
              end
              let!(:second_meeting) do
                create(:meeting, :published, start_time: meeting.start_time.advance(weeks: 1), component: meeting.component, private_meeting: true, transparent: false)
              end
              let!(:meeting_registration) do
                create(:registration, meeting:, user: current_user)
              end

              it "renders only user's invited upcoming private meeting correctly" do
                expect(meetings_ids.length).to eq(1)
                expect(meetings_ids).to include(item_id(meeting))
              end
            end
          end
        end

        context "with no meetings" do
          it "renders nothing" do
            expect(html).to have_no_css(".meeting-list__block-list")
          end
        end
      end
    end
  end
end

def item_id(meeting)
  "meetings__meeting_#{meeting.id}"
end
