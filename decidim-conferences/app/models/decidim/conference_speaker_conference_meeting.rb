# frozen_string_literal: true

module Decidim
  class ConferenceSpeakerConferenceMeeting < ApplicationRecord
    belongs_to :conference_speaker, class_name: "Decidim::ConferenceSpeaker"
    belongs_to :conference_meeting, class_name: "Decidim::ConferenceMeeting"
  end
end
