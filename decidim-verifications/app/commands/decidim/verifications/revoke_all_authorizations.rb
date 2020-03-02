# frozen_string_literal: true

module Decidim
  module Verifications
    # A command to revoken authorizations
    class RevokeAllAuthorizations < Rectify::Command
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
        auths_arr = Decidim::Verifications::Authorizations.new(
          organization: organization,
          granted: true
        ).query.to_a

        auths_arr.each do |auth|
          Decidim.traceability.perform_action!(
            :delete,
            auth,
            current_user
          ) do
            auth.delete
          end
        end

        broadcast(:ok)
      rescue StandardError => e
        broadcast(:invalid, e.message)
      end

      private

      attr_reader :organization, :current_user
    end
  end
end
