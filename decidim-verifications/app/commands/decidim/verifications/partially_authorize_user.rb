# frozen_string_literal: true

module Decidim
  module Verifications
    # A command to create a partial authorization for a user.
    class PartiallyAuthorizeUser < Rectify::Command
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
        return broadcast(:invalid) unless handler.valid?

        create_partial_authorization

        broadcast(:ok)
      end

      protected

      def create_partial_authorization
        authorization = Authorization.find_or_initialize_by(
          user: handler.user,
          name: handler.handler_name
        )

        authorization.attributes = {
          unique_id: handler.unique_id,
          metadata: handler.metadata,
          verification_metadata: handler.verification_metadata,
          verification_attachment: handler.verification_attachment
        }

        authorization.save!
      end

      private

      attr_reader :handler
    end
  end
end
