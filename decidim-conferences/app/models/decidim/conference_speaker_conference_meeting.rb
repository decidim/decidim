# frozen_string_literal: true

module Decidim
  class ConferenceSpeakerConferenceMeeting < ApplicationRecord
    belongs_to :conference_speaker, class_name: "Decidim::ConferenceSpeaker", inverse_of: :conference_speaker_conference_meetings
    belongs_to :conference_meeting, class_name: "Decidim::ConferenceMeeting", inverse_of: :conference_speaker_conference_meetings
  end
end
