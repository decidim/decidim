# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    module ContentBlocks
      describe UpcomingEventsCell, type: :cell do
        controller Decidim::Meetings::Directory::MeetingsController

        let(:html) { cell("decidim/meetings/content_blocks/upcoming_events").call }
        let(:organization) { create(:organization) }
        let(:current_user) { create :user, :admin, :confirmed, organization: organization }
        let(:invited_by) { create(:user, :admin, :confirmed, organization: organization ) }

        before do
          expect(controller).to receive(:current_organization).at_least(:once).and_return(organization)
        end

        context "with events" do
          let(:organization) { meeting.organization }
          let(:meeting) { create(:meeting, start_time: 1.week.from_now) }

          it "renders the events" do
            expect(html).to have_css(".card", count: 1)
          end

          describe "upcoming events" do
            subject { cell.upcoming_events }

            let(:cell) { described_class.new(nil, context: { controller: controller }) }
            let!(:past_meeting) do
              create(:meeting, start_time: 1.week.ago, component: meeting.component)
            end
            let!(:second_meeting) do
              create(:meeting, start_time: meeting.start_time.advance(weeks: 1), component: meeting.component)
            end

            it { is_expected.not_to include(past_meeting) }
            it { is_expected.to include(meeting) }
            it { is_expected.to include(second_meeting) }

            it "orders them correctly" do
              expect(subject.length).to eq(2)
              expect(subject.first).to eq(meeting)
              expect(subject.last).to eq(second_meeting)
            end

            context "with upcoming private events" do
              let!(:meeting) do
                create(:meeting, start_time: 1.week.from_now, private_meeting: true, transparent: false)
              end
              let!(:second_meeting) do
                create(:meeting, start_time: meeting.start_time.advance(weeks: 1), component: meeting.component, private_meeting: true, transparent: false)
              end

              it "renders nothing" do
                expect(subject.length).to eq(0)
              end
            end

            context "with upcoming private events but invited user" do
              let!(:meeting) do
                create(:meeting, start_time: 1.week.from_now, private_meeting: true, transparent: false)
              end
              let!(:second_meeting) do
                create(:meeting, start_time: meeting.start_time.advance(weeks: 1), component: meeting.component, private_meeting: true, transparent: false)
              end
              let(:invite_form_params) do
                {
                  name: current_user.name,
                  email: current_user.email,
                  user_id: current_user.id,
                  existing_user: true
                }
              end
              let(:invite_user_form) do
                Decidim::Meetings::Admin::MeetingRegistrationInviteForm.from_params(invite_form_params)
              end
              let!(:invite_user_to_meeting) do
                Decidim::Meetings::Admin::InviteUserToJoinMeeting.call(invite_user_form, second_meeting, invited_by)
              end

              it "renders only upcoming not private meeting correctly" do
                expect(subject.length).to eq(1)
              end
            end
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
