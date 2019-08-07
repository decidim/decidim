# frozen_string_literal: true

module Decidim
  class EmailNotificationGeneratorJob < ApplicationJob
    queue_as :events

    # rubocop:disable Metrics/ParameterLists
    def perform(event, event_class_name, resource, followers, affected_users, extra)
      return if event_class_name.nil?

      event_class = event_class_name.constantize
      EmailNotificationGenerator.new(event, event_class, resource, followers, affected_users, extra).generate
    end
    # rubocop:enable Metrics/ParameterLists
  end
end
