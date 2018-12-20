# frozen_string_literal: true

module Decidim
  module Conferences
    class ConferenceMeetingRegistrationType < ApplicationRecord
      belongs_to :conference_meeting, foreign_key: "conference_meeting_id", class_name: "Decidim::ConferenceMeeting"
      belongs_to :registration_type, foreign_key: "registration_type_id", class_name: "Decidim::Conferences::RegistrationType"
    end
  end
end
