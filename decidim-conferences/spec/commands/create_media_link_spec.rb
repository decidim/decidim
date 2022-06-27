# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe Admin::CreateMediaLink do
    subject { described_class.new(form, current_user, conference) }

    let(:conference) { create(:conference) }
    let!(:current_user) { create :user, :confirmed, organization: conference.organization }
    let(:form) do
      double(
        Admin::ConferenceSpeakerForm,
        invalid?: invalid,
        title: { en: "title" },
        attributes: {
          "title" => { en: "title" },
          "weight" => Faker::Number.between(from: 1, to: 10),
          "link" => Faker::Internet.url,
          "date" => 5.days.from_now
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
      let(:media_link) { Decidim::Conferences::MediaLink.last }

      it "creates a media link" do
        expect { subject.call }.to change(Decidim::Conferences::MediaLink, :count).by(1)
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "sets the conference" do
        subject.call
        expect(media_link.conference).to eq conference
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with(:create, Decidim::Conferences::MediaLink, current_user, hash_including(resource: hash_including(:title)))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end
    end
  end
end
