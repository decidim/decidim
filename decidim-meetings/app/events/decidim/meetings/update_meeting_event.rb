module Decidim
  module Meetings
    class UpdateMeetingEvent < Decidim::Events::BaseEvent
      include Decidim::Events::NotificationEvent
    end
  end
end
