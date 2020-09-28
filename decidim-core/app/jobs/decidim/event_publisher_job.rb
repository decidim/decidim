# frozen_string_literal: true

module Decidim
  class EventPublisherJob < ApplicationJob
    queue_as :events

    attr_reader :resource

    def perform(event_name, data)
      @resource = data[:resource]

      return unless data[:force_send] || notifiable?

      send_event(NotificationGeneratorJob, event_name, data)
      send_event(EmailNotificationGeneratorJob, event_name, data) if high_priority?(data) || !Decidim.config.batch_email_notifications_enabled || data[:force_send]
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
      return if event_name.blank?

      job_klass.perform_later(
        event_name,
        data[:event_class],
        data[:resource],
        data[:followers],
        data[:affected_users],
        data[:extra]
      )
    end

    # Allows to defined whether an event as to be sent now or to be scheduled
    # Returns boolean
    #   - False if high_priority is undefined, unknown or false
    #   - True if high_priority? is high
    def high_priority?(data)
      data[:extra].fetch(:high_priority, false) # If not defined, high_priority is false by default
    end
  end
end
