# frozen_string_literal: true

module Decidim
  class NotificationGeneratorJob < ApplicationJob
    queue_as :events

    # rubocop:disable Metrics/ParameterLists
    def perform(event, event_class_name, resource, followers, affected_users, extra)
      event_class = event_class_name.constantize
      NotificationGenerator.new(event, event_class, resource, followers, affected_users, extra).generate
    end
    # rubocop:enable Metrics/ParameterLists
  end
end
