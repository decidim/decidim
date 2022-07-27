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
      # - :invalid if the handler wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless @organization

        auths = Decidim::Verifications::Authorizations.new(
          organization:,
          granted: true
        ).query

        auths.find_each do |auth|
          Decidim.traceability.perform_action!(
            :destroy,
            auth,
            current_user
          ) do
            auth.destroy
          end
        end

        broadcast(:ok)
      end

      private

      attr_reader :organization, :current_user
    end
  end
end
