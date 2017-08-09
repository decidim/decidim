# frozen_string_literal: true

module Decidim
  class NotificationGeneratorJob < ApplicationJob
    queue_as :decidim_events

    def perform(event, event_class_name, followable)
      event_class = event_class_name.constantize
      NotificationGenerator.new(event, event_class, followable).generate
    end
  end
end
