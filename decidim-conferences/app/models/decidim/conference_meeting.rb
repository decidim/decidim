# frozen_string_literal: true

module Decidim
  # It represents a meeting of the conference
  class ConferenceMeeting < Decidim::Meetings::Meeting
    has_many :conference_speaker_conference_meetings, dependent: :destroy
    has_many :conference_speakers, through: :conference_speaker_conference_meetings, foreign_key: "conference_meeting_id", class_name: "Decidim::ConferenceSpeaker"
  end
end
