# frozen_string_literal: true

module Decidim
  module Conferences
    class ConferenceMeetingRegistrationType < ApplicationRecord
      belongs_to :conference_meeting, class_name: "Decidim::ConferenceMeeting"
      belongs_to :registration_type, class_name: "Decidim::Conferences::RegistrationType"
    end
  end
end
