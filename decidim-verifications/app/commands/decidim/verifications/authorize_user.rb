# frozen_string_literal: true

module Decidim
  module Verifications
    # A command to authorize a user with an authorization handler.
    class AuthorizeUser < Rectify::Command
      # Public: Initializes the command.
      #
      # handler - An AuthorizationHandler object.
      def initialize(handler)
        @handler = handler
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the handler wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        if handler.invalid?
          conflict = create_verification_conflict
          notify_admins(conflict) if conflict.present?

          return broadcast(:invalid)
        end

        Authorization.create_or_update_from(handler)

        broadcast(:ok)
      end

      private

      attr_reader :handler

      def notify_admins(conflict)
        Decidim::EventsManager.publish(
          event: "decidim.events.verifications.managed_user_error_event",
          event_class: Decidim::Verifications::ManagedUserErrorEvent,
          resource: conflict,
          affected_users: Decidim::User.where(admin: true)
        )
      end

      def create_verification_conflict
        document_number = handler.try(:document_number).presence || handler.try(:document_passport)
        authorization = Decidim::Authorization.find_by(unique_id: document_number)
        return if authorization.blank?

        conflict = Decidim::Verifications::Conflict.find_or_initialize_by(
          current_user: handler.user,
          managed_user: authorization.user,
          document_number: handler.document_number
        )

        conflict.update(times: conflict.times + 1)

        conflict
      end
    end
  end
end
