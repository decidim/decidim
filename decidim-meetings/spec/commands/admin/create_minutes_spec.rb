# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Admin::CreateMinutes do
    subject { described_class.new(form, meeting) }

    let(:organization) { create :organization, available_locales: [:en] }
    let(:current_user) { create :user, :admin, :confirmed, organization: organization }
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:current_component) { create :component, participatory_space: participatory_process, manifest_name: "meetings" }
    let(:meeting) { create :meeting, component: current_component }
    let(:description) { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(word_count: 4) } }
    let(:video_url) { Faker::Internet.url }
    let(:audio_url) { Faker::Internet.url }
    let(:visible) { true }
    let(:invalid) { false }

    let(:form) do
      double(
        invalid?: invalid,
        description: description,
        video_url: video_url,
        audio_url: audio_url,
        visible: visible,
        current_user: current_user
      )
    end

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      let(:minutes) { Minutes.last }

      it "creates the minute" do
        expect { subject.call }.to change(Minutes, :count).by(1)
      end

      it "sets the meeting" do
        subject.call
        expect(minutes.meeting).to eq meeting
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:create!)
          .with(
            Decidim::Meetings::Minutes,
            form.current_user,
            kind_of(Hash),
            resource: {
              title: meeting.title
            },
            participatory_space: {
              title: participatory_process.title
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
