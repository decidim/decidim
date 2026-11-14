# frozen_string_literal: true

module Decidim
  module Conferences
    class ConferenceMeetingRegistrationType < ApplicationRecord
      belongs_to :conference_meeting, class_name: "Decidim::ConferenceMeeting", inverse_of: :conference_meeting_registration_types
      belongs_to :registration_type, class_name: "Decidim::Conferences::RegistrationType", counter_cache: true, inverse_of: :conference_meeting_registration_types
    end
  end
end
