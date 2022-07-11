# frozen_string_literal: true

module Decidim
  module Verifications
    # A command to authorize a user with an authorization handler.
    class AuthorizeUser < Decidim::Command
      # Public: Initializes the command.
      #
      # handler - An AuthorizationHandler object.
      def initialize(handler, organization)
        @handler = handler
        @organization = organization
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the handler wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return transfer_authorization if !handler.unique? && handler.transferrable?

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

      def transfer_authorization
        authorization = handler.duplicate
        transfer = authorization.transfer!(handler)

        if transfer
          broadcast(:transferred, transfer)
        else
          broadcast(:invalid)
        end
      rescue Decidim::AuthorizationTransfer::DisabledError
        broadcast(:invalid)
      end

      def notify_admins(conflict)
        Decidim::EventsManager.publish(
          event: "decidim.events.verifications.managed_user_error_event",
          event_class: Decidim::Verifications::ManagedUserErrorEvent,
          resource: conflict,
          affected_users: @organization.admins
        )
      end

      def create_verification_conflict
        authorization = Decidim::Authorization.find_by(unique_id: handler.unique_id)
        return if authorization.blank?

        conflict = Decidim::Verifications::Conflict.find_or_initialize_by(
          current_user: handler.user,
          managed_user: authorization.user,
          unique_id: handler.unique_id
        )

        conflict.update(times: conflict.times + 1)

        conflict
      end
    end
  end
end
