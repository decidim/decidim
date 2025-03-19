# frozen_string_literal: true

module Decidim
  module Events
    autoload :BaseEvent, "decidim/events/base_event"
    autoload :EmailEvent, "decidim/events/email_event"
    autoload :NotificationEvent, "decidim/events/notification_event"
    autoload :SimpleEvent, "decidim/events/simple_event"
    autoload :AuthorEvent, "decidim/events/author_event"
    autoload :CoauthorEvent, "decidim/events/coauthor_event"
    autoload :MachineTranslatedEvent, "decidim/events/machine_translated_event"
  end
end
