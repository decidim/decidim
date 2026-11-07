# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ConferenceSpeakerConferenceMeeting do
    subject { conference_speaker_conference_meeting }

    let(:conference) { create(:conference) }
    let(:component) { create(:component, manifest_name: :meetings, participatory_space: conference) }
    let(:conference_speaker) { create(:conference_speaker, conference:) }
    let(:conference_meeting) { create(:conference_meeting, conference:, component:) }
    let(:conference_speaker_conference_meeting) { create(:conference_speaker_conference_meeting, conference_speaker:, conference_meeting:) }

    it { is_expected.to be_valid }

    it "uses the conference speaker's conference_speaker_conference_meetings association as the inverse" do
      expect(conference_speaker_conference_meeting.conference_speaker.conference_speaker_conference_meetings.first.conference_speaker).to be(conference_speaker)
    end

    it "uses the conference meeting's conference_speaker_conference_meetings association as the inverse" do
      expect(conference_speaker_conference_meeting.conference_meeting.conference_speaker_conference_meetings.first.conference_meeting).to be(conference_meeting)
    end
  end
end
