# frozen_string_literal: true

module Decidim
  class EmailNotificationGeneratorJob < ApplicationJob
    queue_as :events

    # rubocop:disable Metrics/ParameterLists
    def perform(event, event_class_name, resource, followers, affected_users, priority, extra)
      event_class = event_class_name&.safe_constantize
      return if event_class.blank?

      EmailNotificationGenerator.new(event, event_class, resource, followers, affected_users, priority, extra).generate
    end
    # rubocop:enable Metrics/ParameterLists
  end
end
