# frozen_string_literal: true

module Decidim
  class NotificationGeneratorForFollowerJob < ApplicationJob
    queue_as :decidim_events

    def perform(event, followable, follower)
      NotificationGeneratorForFollower.new(event, followable, follower).generate
    end
  end
end
