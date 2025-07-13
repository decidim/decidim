# frozen_string_literal: true

module Decidim
  module Meetings
    class RegistrationMarkedAsAttendeeEvent < Decidim::Events::SimpleEvent
      include Decidim::Meetings::MeetingEvent
    end
  end
end
