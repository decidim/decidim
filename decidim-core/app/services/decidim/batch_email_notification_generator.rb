# frozen_string_literal: true

module Decidim
  class BatchEmailNotificationGenerator
    def initialize
      @events = events
    end

    def generate
      users.each do |user|
        BatchNotificationMailer.event_received(events_for(user), Decidim::User.find(user)).deliver_later
      end
    end

    private

    def events
      @events ||= Decidim::Notification.where("created_at > ?", 24.hours.ago).order(created_at: :desc)
    end

    def events_for(user)
      @events.where(decidim_user_id: user).map do |event|
        {
            resource: event.resource,
            event_class: event.event_class,
            event_name: event.event_name,
            user: event.user,
            extra: event.extra,
            user_role: event.user_role
        }
      end
    end

    def users
      @events.pluck(:decidim_user_id).uniq
    end
  end
end
