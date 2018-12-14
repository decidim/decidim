# frozen_string_literal: true

module Decidim
  class EmailNotificationGeneratorJob < ApplicationJob
    queue_as :events

    # rubocop:disable Metrics/ParameterLists
    def perform(event, event_class_name, resource, followers, affected_users, extra)
      event_class = event_class_name.constantize
      recipient_ids = followers.compact.map(&:id) + affected_users.compact.map(&:id)
      EmailNotificationGenerator.new(event, event_class, resource, recipient_ids, extra).generate
    end
    # rubocop:enable Metrics/ParameterLists
  end
end
