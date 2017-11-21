# frozen_string_literal: true

module Decidim
  class NotificationGeneratorJob < ApplicationJob
    queue_as :events

    def perform(event, event_class_name, resource, recipient_ids, extra)
      event_class = event_class_name.constantize
      NotificationGenerator.new(event, event_class, resource, recipient_ids, extra).generate
    end
  end
end
