# frozen_string_literal: true

module Decidim
  module Verifications
    # A command to revoke authorizations by name
    class RevokeByNameAuthorizations < Decidim::Command
      # Public: Initializes the command.
      #
      # organization - Organization object.
      # name - Authorizations handler name
      # current_user - The current user.
      def initialize(organization, name, current_user)
        @organization = organization
        @current_user = current_user
        @name = name
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the handler was not valid and we could not proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless [organization, name].all?(&:present?)

        auths = Decidim::Verifications::Authorizations.new(
          organization:,
          name:,
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

      attr_reader :organization, :name, :current_user
    end
  end
end
