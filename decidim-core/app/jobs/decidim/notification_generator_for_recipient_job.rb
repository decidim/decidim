# frozen_string_literal: true

module Decidim
  class NotificationGeneratorForRecipientJob < ApplicationJob
    queue_as :events

    def perform(event, event_class_name, resource, recipient, user_role, extra) # rubocop:disable Metrics/ParameterLists
      event_class = event_class_name.constantize
      NotificationGeneratorForRecipient
        .new(event, event_class, resource, recipient, user_role, extra)
        .generate
    end
  end
end
