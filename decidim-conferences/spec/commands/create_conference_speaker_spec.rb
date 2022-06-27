# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe Admin::CreateConferenceSpeaker do
    subject { described_class.new(form, current_user, conference) }

    let(:conference) { create(:conference) }
    let(:user) { nil }
    let!(:current_user) { create :user, :confirmed, organization: conference.organization }
    let(:meeting_component) do
      create(:component, manifest_name: :meetings, participatory_space: conference)
    end

    let(:meetings) do
      create_list(
        :meeting,
        3,
        component: meeting_component
      )
    end
    let(:meeting_ids) { meetings.map(&:id) }
    let(:avatar) do
      ActiveStorage::Blob.create_and_upload!(
        io: File.open(Decidim::Dev.asset("avatar.jpg")),
        filename: "avatar.jpeg",
        content_type: "image/jpeg"
      )
    end

    let(:full_name) { "Full name" }
    let(:position) { Decidim::Faker::Localized.word }
    let(:affiliation) { Decidim::Faker::Localized.word }
    let(:short_bio) { Decidim::Faker::Localized.sentence }
    let(:twitter_handle) { "full_name" }
    let(:personal_url) { "http://decidim.org" }
    let(:existing_user) { false }
    let(:user_id) { nil }

    let(:form_klass) { Admin::ConferenceSpeakerForm }
    let(:form_params) do
      {
        conference_speaker: {
          full_name:,
          position:,
          affiliation:,
          short_bio:,
          twitter_handle:,
          personal_url:,
          avatar:,
          existing_user:,
          user_id:,
          conference_meeting_ids: meeting_ids
        }
      }
    end
    let(:form) do
      form_klass.from_params(
        form_params
      ).with_context(
        current_user:,
        current_organization: conference.organization
      )
    end

    context "when the form is not valid" do
      let(:full_name) { nil }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end

      context "when image is invalid" do
        let(:avatar) do
          ActiveStorage::Blob.create_and_upload!(
            io: File.open(Decidim::Dev.asset("invalid.jpeg")),
            filename: "avatar.jpeg",
            content_type: "image/jpeg"
          )
        end

        it "prevents uploading" do
          expect { subject.call }.not_to raise_error
          expect { subject.call }.to broadcast(:invalid)
        end
      end
    end

    context "when everything is ok" do
      let(:conference_speaker) { Decidim::ConferenceSpeaker.last }

      it "creates an conference" do
        expect { subject.call }.to change(Decidim::ConferenceSpeaker, :count).by(1)
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "sets the conference" do
        subject.call
        expect(conference_speaker.conference).to eq conference
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with(:create, Decidim::ConferenceSpeaker, current_user, hash_including(resource: hash_including(:title)))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end

      context "with an existing user in the platform" do
        let!(:user) { create(:user, organization: conference.organization) }
        let!(:user_id) { user.id }

        it "sets the user" do
          subject.call
          expect(conference_speaker.user).to eq user
        end
      end

      it "links meetings" do
        subject.call

        conference_meetings = []
        meetings.each do |meeting|
          conference_meetings << meeting.becomes(Decidim::ConferenceMeeting)
        end

        conference_speaker.conference_meetings = conference_meetings
        expect(conference_speaker.conference_meetings).to match_array(conference_meetings)
      end
    end
  end
end
