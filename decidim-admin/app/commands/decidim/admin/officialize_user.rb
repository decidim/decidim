# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when officializing a user.
    class OfficializeUser < Decidim::Command
      # Public: Initializes the command.
      #
      # form - The officialization form.
      def initialize(form)
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when the officialization suceeds.
      # - :invalid when the form is invalid.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless form.valid?

        officialize_user

        Decidim::EventsManager.publish(
          event: "decidim.events.users.user_officialized",
          event_class: Decidim::ProfileUpdatedEvent,
          resource: form.user,
          followers: form.user.followers
        )

        broadcast(:ok, form.user)
      end

      private

      attr_reader :form

      def officialize_user
        timestamp = Time.current
        Decidim.traceability.perform_action!(
          "officialize",
          form.user,
          form.current_user,
          extra: {
            officialized_user_badge: form.officialized_as,
            officialized_user_badge_previous: form.user.officialized_as,
            officialized_user_at: timestamp,
            officialized_user_at_previous: form.user.officialized_at
          }
        ) do
          form.user.update!(
            officialized_at: timestamp,
            officialized_as: form.officialized_as
          )
        end
      end
    end
  end
end
