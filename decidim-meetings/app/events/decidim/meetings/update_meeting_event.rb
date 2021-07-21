# frozen_string_literal: true

module Decidim
  module Meetings
    class UpdateMeetingEvent < Decidim::Events::SimpleEvent
      include Decidim::Meetings::MeetingEvent
    end
  end
end
