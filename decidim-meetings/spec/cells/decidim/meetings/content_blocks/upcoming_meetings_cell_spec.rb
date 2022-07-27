# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    module ContentBlocks
      describe UpcomingMeetingsCell, type: :cell do
        controller Decidim::Meetings::Directory::MeetingsController

        let(:html) { cell("decidim/meetings/content_blocks/upcoming_meetings").call }
        let(:organization) { create(:organization) }
        let(:current_user) { create :user, :confirmed, organization: }

        before do
          expect(controller).to receive(:current_organization).at_least(:once).and_return(organization)
        end

        context "with meetings" do
          let(:organization) { meeting.organization }
          let(:meeting) { create(:meeting, :published, start_time: 1.week.from_now) }

          it "renders the meetings" do
            expect(html).to have_css(".card", count: 1)
          end

          describe "upcoming meetings" do
            subject { cell.upcoming_meetings }

            let(:cell) { described_class.new(nil, context: { controller: }) }
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

            it { is_expected.not_to include(moderated_meeting) }
            it { is_expected.not_to include(past_meeting) }
            it { is_expected.to include(meeting) }
            it { is_expected.to include(second_meeting) }
            it { is_expected.not_to include(unpublished_meeting) }

            it "orders them correctly" do
              expect(subject.length).to eq(2)
              expect(subject.first).to eq(meeting)
              expect(subject.last).to eq(second_meeting)
            end

            context "with upcoming private meetings" do
              let!(:meeting) do
                create(:meeting, :published, start_time: 1.week.from_now, private_meeting: true, transparent: false)
              end
              let!(:second_meeting) do
                create(:meeting, :published, start_time: meeting.start_time.advance(weeks: 1), component: meeting.component, private_meeting: true, transparent: false)
              end

              it "renders nothing" do
                expect(subject.length).to eq(0)
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
                expect(subject.length).to eq(1)
              end
            end
          end
        end

        context "with no meetings" do
          it "renders nothing" do
            expect(html).to have_no_css(".upcoming-meetings")
          end
        end
      end
    end
  end
end
