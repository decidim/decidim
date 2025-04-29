# frozen_string_literal: true

module Decidim
  #
  # Decorator for notifications in mail digest
  #
  class NotificationToMailerPresenter < SimpleDelegator
    include Decidim::TranslatableAttributes

    EXTENDED_NOTIFICATIONS_CLASSES = [
      "Decidim::Comments::CommentCreatedEvent"
    ].freeze

    delegate :url_helpers, to: "Decidim::Core::Engine.routes"
    delegate :resource_title, to: :event
    delegate :resource_url, to: :event
    delegate :email_intro, to: :event
    delegate :resource_path, to: :event
    delegate :safe_resource_text, to: :event

    def date_time
      created_at_in_time_zone = created_at.in_time_zone(resource.organization.time_zone)
      if frequency == :daily
        I18n.l(created_at_in_time_zone, format: :time_of_day)
      else
        I18n.l(created_at_in_time_zone, format: :decidim_short)
      end
    end

    def show_extended_information?
      EXTENDED_NOTIFICATIONS_CLASSES.include?(event_class)
    end

    private

    def event
      @event ||= event_class.constantize.new(
        resource:,
        user:,
        user_role:,
        event_name:,
        extra:
      )
    end

    def frequency
      @frequency ||= user.notifications_sending_frequency
    end
  end
end
