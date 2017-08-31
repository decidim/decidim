# frozen_string_literal: true

module Decidim
  module Events
    autoload :BaseEvent, "decidim/events/base_event"
    autoload :EmailEvent, "decidim/events/email_event"
    autoload :NotificationEvent, "decidim/events/notification_event"
  end
end
