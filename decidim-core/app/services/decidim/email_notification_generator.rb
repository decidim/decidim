# frozen_string_literal: true

module Decidim
  # This class handles system events affecting resources and generates a
  # notification for each recipient by scheduling a new
  # `Decidim::NotificationMailer` job for each of them. This way we can
  # easily control which jobs fail and retry them, so that we do not have
  # duplicated notifications.
  class EmailNotificationGenerator
    # Initializes the class.
    #
    # event - A String with the name of the event.
    # event_class - A class that wraps the event.
    # resource - an instance of a class implementing the `Decidim::Resource` concern.
    # followers - a collection of Users that receive the notification because
    #   they are following it
    # affected_users - a collection of Users that receive the notification because
    #   they are affected by it
    # extra - a Hash with extra information to be included in the notification.
    # rubocop:disable Metrics/ParameterLists
    def initialize(event, event_class, resource, followers, affected_users, extra)
      @event = event
      @event_class = event_class
      @resource = resource
      @followers = followers
      @affected_users = affected_users
      @extra = extra
    end
    # rubocop:enable Metrics/ParameterLists

    # Schedules a job for each recipient to send the email. Returns `nil`
    # if the resource is not resource or if it is not present.
    #
    # Returns nothing.
    def generate
      return unless resource
      return unless event_class.types.include?(:email)

      send_to_followers
      send_to_affected_users
    end

    private

    def send_to_affected_users
      affected_users.each do |recipient|
        next unless ["all", "own-only"].include?(recipient.notification_types)
        next if recipient.deleted? || recipient.blocked?

        send_email_to(recipient, user_role: :affected_user)
      end
    end

    def send_to_followers
      followers.each do |recipient|
        next unless ["all", "followed-only"].include?(recipient.notification_types)
        next if recipient.deleted? || recipient.blocked?

        send_email_to(recipient, user_role: :follower)
      end
    end

    attr_reader :event, :event_class, :resource, :followers, :affected_users, :extra

    # Private: sends the notification email to the user if they have the
    # `notifications_sending_frequency` set to real_time.
    #
    # recipient - The user that will receive the email.
    # user_role - the role the user takes for this notification (either
    #   `:follower` or `:affected_user`)
    #
    # Returns nothing.
    def send_email_to(recipient, user_role:)
      return unless recipient
      return unless should_send_email?(recipient)
      return if resource.respond_to?(:can_participate?) && !resource.can_participate?(recipient)

      wait_time = 0
      wait_time = Decidim.machine_translation_delay.to_i + 1.minute if recipient.organization.enable_machine_translations

      NotificationMailer
        .event_received(
          event,
          event_class.name,
          resource,
          recipient,
          user_role.to_s,
          extra
        )
        .deliver_later(wait: wait_time)
    end

    def should_send_email?(recipient)
      return extra[:force_email] if extra.has_key?(:force_email)

      recipient.notifications_sending_frequency == "real_time"
    end

    def component
      return resource.component if resource.is_a?(Decidim::HasComponent)

      resource if resource.is_a?(Decidim::Component)
    end

    def participatory_space
      return resource if resource.is_a?(Decidim::ParticipatorySpaceResourceable)

      component&.participatory_space
    end
  end
end
