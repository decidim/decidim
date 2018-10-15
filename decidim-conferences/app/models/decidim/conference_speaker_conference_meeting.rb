# frozen_string_literal: true

module Decidim
  class ConferenceSpeakerConferenceMeeting < ApplicationRecord
    belongs_to :conference_speaker, foreign_key: "conference_speaker_id", class_name: "Decidim::ConferenceSpeaker"
    belongs_to :conference_meeting, foreign_key: "conference_meeting_id", class_name: "Decidim::ConferenceMeeting"
  end
end
