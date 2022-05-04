# frozen_string_literal: true

module Decidim
  # It represents a meeting of the conference
  class ConferenceMeeting < Decidim::Meetings::Meeting
    translatable_fields(*Decidim::Meetings::Meeting.translatable_fields_list)

    has_many :conference_speaker_conference_meetings, dependent: :destroy
    has_many :conference_speakers, through: :conference_speaker_conference_meetings, class_name: "Decidim::ConferenceSpeaker"
    has_many :conference_meeting_registration_types, dependent: :destroy, class_name: "Decidim::Conferences::ConferenceMeetingRegistrationType"
    has_many :registration_types, through: :conference_meeting_registration_types, foreign_key: "registration_type_id", class_name: "Decidim::Conferences::RegistrationType"
  end
end
