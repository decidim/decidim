# frozen-string_literal: true

module Decidim
  module Meetings
    class MeetingRegistrationsEnabledEvent < Decidim::Events::SimpleEvent
      include Decidim::Meetings::MeetingEvent
    end
  end
end
