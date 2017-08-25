# frozen-string_literal: true

module Decidim
  module Meetings
    class CloseMeetingEvent < Decidim::Events::BaseEvent
      include Decidim::Events::EmailEvent
      include Decidim::Events::NotificationEvent
    end
  end
end
