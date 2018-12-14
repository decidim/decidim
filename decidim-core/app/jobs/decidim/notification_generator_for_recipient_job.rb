# frozen_string_literal: true

module Decidim
  class NotificationGeneratorForRecipientJob < ApplicationJob
    queue_as :events

    def perform(event, event_class_name, resource, recipient, extra)
      event_class = event_class_name.constantize
      NotificationGeneratorForRecipient
        .new(event, event_class, resource, recipient, extra)
        .generate
    end
  end
end
