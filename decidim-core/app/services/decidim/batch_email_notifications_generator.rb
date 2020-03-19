# frozen_string_literal: true

module Decidim
  class BatchEmailNotificationsGenerator
    include ActionView::Helpers::DateHelper

    def initialize
      @events = events
    end

    def generate
      return if events.empty?

      users.each do |user|
        BatchNotificationsMailer.event_received(
          serialized_events(events_for(user)),
          Decidim::User.find(user)
        ).deliver_later

        mark_as_sent(events_for(user))
      end
    end

    private

    def events
      @events ||= Decidim::Notification.from_last(Decidim.config.batch_email_notifications_interval)
                                       .unsent
                                       .order(created_at: :desc)
                                       .limit(Decidim.config.batch_email_notifications_max_length)
    end

    def events_for(user)
      events.where(decidim_user_id: user)
    end

    def serialized_events(events)
      events.map do |event|
        {
          resource: event.resource,
          event_class: event.event_class,
          event_name: event.event_name,
          user: event.user,
          extra: event.extra,
          user_role: event.user_role,
          created_at: time_ago_in_words(event.created_at).capitalize
        }
      end
    end

    def mark_as_sent(events)
      # rubocop:disable Rails/SkipsModelValidations
      events.in_batches.update_all(sent_at: Time.zone.now)
      # rubocop:enable Rails/SkipsModelValidations
    end

    def users
      events.pluck(:decidim_user_id).uniq
    end
  end
end
