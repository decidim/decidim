# frozen_string_literal: true

module Decidim
  class NotificationMailerPreview < ActionMailer::Preview
    def event_received
      NotificationMailer.event_received(event, event_class_name, resource, user, user_role, extra)
    end

    private

    def event = "decidim.events.users.profile_updated"

    def event_class_name = "Decidim::ProfileUpdatedEvent"

    def resource = User.first

    def user = User.second

    def user_role = :follower

    def extra = {}
  end
end
