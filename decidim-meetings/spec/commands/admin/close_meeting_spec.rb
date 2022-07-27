# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Admin::CloseMeeting do
    subject { described_class.new(form, meeting) }

    let(:meeting) { create :meeting }
    let(:user) { create :user, :admin }
    let(:video_url) { Faker::Internet.url }
    let(:audio_url) { Faker::Internet.url }
    let(:closing_visible) { true }
    let(:form) do
      double(
        invalid?: invalid,
        closing_report: { en: "Great meeting" },
        attendees_count: 10,
        contributions_count: 15,
        attending_organizations: "Some organization",
        closed_at: Time.current,
        proposal_ids:,
        current_user: user,
        video_url:,
        audio_url:,
        closing_visible:
      )
    end
    let(:proposal_component) do
      create(:component, manifest_name: :proposals, participatory_space: meeting.component.participatory_space)
    end
    let(:invalid) { false }
    let(:proposals) do
      create_list(
        :proposal,
        3,
        component: proposal_component
      )
    end
    let(:proposal_ids) { proposals.map(&:id) }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end

      it "doesn't perform any other action" do
        expect(meeting).not_to receive(:update!)
        expect(Decidim::ResourceLink).not_to receive(:create!)

        subject.call
      end
    end

    context "when everything is ok" do
      it "updates the meeting with the closing details" do
        subject.call

        expect(meeting).to be_closed
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with(:close, meeting, user)
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end

      context "when previous proposals had been linked" do
        let(:previous_proposals) { create_list(:proposal, 3, component: proposal_component) }

        before do
          meeting.link_resources(previous_proposals, "proposals_from_meeting")
        end

        it "unlinks them" do
          expect(meeting.linked_resources(:proposals, "proposals_from_meeting")).to match_array(previous_proposals)

          subject.call

          expect(meeting.linked_resources(:proposals, "proposals_from_meeting").length).to eq(3)
          expect(meeting.linked_resources(:proposals, "proposals_from_meeting")).not_to match_array(previous_proposals)
          expect(meeting.linked_resources(:proposals, "proposals_from_meeting")).to match_array(proposals)
        end
      end

      it "links to the given proposals" do
        subject.call

        expect(meeting.linked_resources(:proposals, "proposals_from_meeting").length).to eq(3)
        expect(meeting.linked_resources(:proposals, "proposals_from_meeting")).to match_array(proposals)
      end

      describe "events" do
        let!(:follow) { create :follow, followable: meeting, user: }

        it "notifies the change" do
          expect(Decidim::EventsManager)
            .to receive(:publish)
            .with(
              event: "decidim.events.meetings.meeting_closed",
              event_class: CloseMeetingEvent,
              resource: meeting,
              followers: [user]
            )

          subject.call
        end
      end
    end
  end
end
