# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Admin::UpdateMinute do
    subject { described_class.new(form, meeting, minute) }

    let(:meeting) { create(:meeting) }
    let(:minute) { create(:minute, meeting: meeting) }
    let(:user) { create :user, :admin }
    let(:video_url) { Faker::Internet.url }
    let(:audio_url) { Faker::Internet.url }
    let(:is_visible) { true }
    let(:invalid) { false }
    let(:form) do
      double(
        invalid?: invalid,
        description: { en: "description" },
        video_url: video_url,
        audio_url: audio_url,
        is_visible: is_visible,
        current_user: user
      )
    end

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "updates the minute" do
        subject.call
        expect(translated(minute.description)).to eq "description"
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:update!)
          .with(
            minute,
            user,
            {
              description: form.description,
              video_url: form.video_url,
              audio_url: form.audio_url,
              is_visible: form.is_visible,
              meeting: meeting
            },
            resource: {
              title: meeting.title
            },
            participatory_space: {
              title: meeting.participatory_space.title
            }
          )
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end
    end
  end
end
