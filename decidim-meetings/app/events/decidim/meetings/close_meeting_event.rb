module Decidim
  module Meetings
    class CloseMeetingEvent < Decidim::Events::BaseEvent
      include Decidim::Events::NotificationEvent
    end
  end
end
