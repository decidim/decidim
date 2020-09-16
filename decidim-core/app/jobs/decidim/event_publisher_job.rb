# frozen_string_literal: true

module Decidim
  class EventPublisherJob < ApplicationJob
    queue_as :events

    attr_reader :resource

    def perform(event_name, data)
      @resource = data[:resource]

      return unless data[:force_send] || notifiable?

      send_event(NotificationGeneratorJob, event_name, data)
      send_event(EmailNotificationGeneratorJob, event_name, data) unless Decidim.config.batch_email_notifications_enabled
    end

    private

    # Whether this event should be notified or not. Useful when you want the
    # event to decide based on the params.
    #
    # It returns false when the resource or any element in the chain is a
    # `Decidim::Publicable` and it isn't published or participatory_space
    # is a `Decidim::Participable` and the user can't participate.
    def notifiable?
      return false if resource.is_a?(Decidim::Publicable) && !resource.published?
      return false if participatory_space.is_a?(Decidim::Publicable) && !participatory_space&.published?
      return false if component && !component.published?

      true
    end

    def component
      return resource.component if resource.is_a?(Decidim::HasComponent)

      resource if resource.is_a?(Decidim::Component)
    end

    def participatory_space
      return resource if resource.is_a?(Decidim::ParticipatorySpaceResourceable)

      component&.participatory_space
    end

    # Call perform_later on Job class passing event_name and data parameters
    def send_event(job_klass, event_name, data)
      job_klass.perform_later(
        event_name,
        data[:event_class],
        data[:resource],
        data[:followers],
        data[:affected_users],
        data[:extra]
      )
    end
  end
end
