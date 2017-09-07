# frozen_string_literal: true

module Decidim
  class NotificationGeneratorForRecipientJob < ApplicationJob
    queue_as :decidim_events

    def perform(event, event_class_name, resource, recipient_id)
      event_class = event_class_name.constantize
      NotificationGeneratorForRecipient
        .new(event, event_class, resource, recipient_id)
        .generate
    end
  end
end
