# frozen_string_literal: true

module Decidim
  module Verifications
    # A command to revoke authorizations
    class RevokeAllAuthorizations < Decidim::Command
      # Public: Initializes the command.
      #
      # organization - Organization object.
      # current_user - The current user.
      def initialize(organization, current_user)
        @organization = organization
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the handler was not valid and we could not proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless @organization

        RevokeAllAuthorizationsJob.perform_later(organization, current_user)

        broadcast(:ok)
      end

      private

      attr_reader :organization, :current_user
    end
  end
end
