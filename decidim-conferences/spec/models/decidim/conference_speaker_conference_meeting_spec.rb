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
  end
end
