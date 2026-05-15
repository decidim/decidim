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
      # - :invalid if the handler was not valid and we could not proceed.
      # - :transferred if there is a duplicated authorization associated
      #                to other user and the authorization can be
      #                transferred.
      # - :transfer_user if there is a duplicated authorization associated
      #                  to an ephemeral user and the current user is also
      #                  ephemeral the session is transferred to the user
      #                  with the existing authorization
      #
      # Returns nothing.
      def call
        if !handler.unique? && handler.user_transferrable?
          handler.user = handler.duplicate.user
          Authorization.create_or_update_from(handler)
          return broadcast(:transfer_user, handler.user)
        end

        return transfer_authorization if !handler.unique? && handler.transferrable?

        if handler.invalid?
          register_conflict

          return broadcast(:invalid)
        end

        return broadcast(:invalid) unless set_tos_agreement

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
        register_conflict

        broadcast(:invalid)
      end

      def register_conflict
        conflict = create_verification_conflict
        notify_admins(conflict) if conflict.present?
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

      def set_tos_agreement
        user = handler.user

        return true if user.tos_accepted? || !user.ephemeral?
        return unless handler.try(:tos_agreement)

        user.update(accepted_tos_version: @organization.tos_version)
      end
    end
  end
end
