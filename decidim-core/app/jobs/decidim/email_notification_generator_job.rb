# frozen_string_literal: true

module Decidim
  class EmailNotificationGeneratorJob < ApplicationJob
    queue_as :decidim_events

    def perform(event, event_class_name, followable, recipient_ids)
      event_class = event_class_name.constantize
      EmailNotificationGenerator.new(event, event_class, followable, recipient_ids).generate
    end
  end
end
