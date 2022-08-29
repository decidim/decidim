# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe Admin::UpdateMediaLink do
    subject { described_class.new(form, media_link) }

    let!(:conference) { create(:conference) }
    let(:media_link) { create :media_link, conference: }
    let!(:current_user) { create :user, :confirmed, organization: conference.organization }

    let(:form) do
      double(
        Admin::ConferenceSpeakerForm,
        invalid?: invalid,
        current_user:,
        title: { en: "New title" },
        attributes: {
          "title" => { en: "New title" },
          "weight" => media_link.weight,
          "link" => media_link.link,
          "date" => 7.days.from_now
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
      it "updates the media link title" do
        expect do
          subject.call
        end.to change { media_link.reload && media_link.title }.from(media_link.title).to("en" => "New title", "machine_translations" => kind_of(Hash))
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:update!)
          .with(media_link, current_user, kind_of(Hash), hash_including(resource: hash_including(:title)))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end
    end
  end
end
