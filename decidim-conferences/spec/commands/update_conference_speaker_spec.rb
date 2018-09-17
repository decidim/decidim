# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe Admin::UpdateConferenceSpeaker do
    subject { described_class.new(form, conference_speaker) }

    let!(:conference) { create(:conference) }
    let(:conference_speaker) { create :conference_speaker, :with_user, conference: conference }
    let!(:current_user) { create :user, :confirmed, organization: conference.organization }
    let(:user) { nil }
    let(:form) do
      instance_double(
        Admin::ConferenceSpeakerForm,
        invalid?: invalid,
        current_user: current_user,
        full_name: "New name",
        user: user,
        attributes: {
          full_name: "New name",
          position: { en: "new position" },
          affiliation: { en: "new affiliation" },
          short_bio: Decidim::Faker::Localized.sentence(5),
          twitter_handle: "full_name",
          personal_url: Faker::Internet.url
        }
      )
    end
    let(:invalid) { false }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      it "updates the conference full name" do
        expect do
          subject.call
        end.to change { conference_speaker.reload && conference_speaker.full_name }.from(conference_speaker.full_name).to("New name")
      end

      it "broadcasts  ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:update!)
          .with(conference_speaker, current_user, kind_of(Hash), hash_including(resource: hash_including(:title)))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end

      context "when is an existing user in the platform" do
        let!(:user) { create :user, organization: conference.organization }

        it "sets the user" do
          expect do
            subject.call
          end.to change { conference_speaker.reload && conference_speaker.user }.from(conference_speaker.user).to(user)
        end
      end
    end
  end
end
