# frozen_string_literal: true

module Decidim
  module Amendable
    # A command with all the business logic when a user starts amending a resource.
    class Withdraw < Rectify::Command
      # Public: Initializes the command.
      #
      # emendation     - The resource to withdraw.
      # current_user - The current user.
      def initialize(emendation, current_user)
        @emendation = emendation
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the resource.
      # - :invalid if the resource already has supports or does not belong to current user.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if @emendation.votes.any?

        transaction do
          change_amendment_state_to_withdrawn
          change_emendation_state_to_withdrawn
        end

        broadcast(:ok, @emendation)
      end

      private

      def change_amendment_state_to_withdrawn
        @emendation.amendment.update state: "withdrawn"
      end

      def change_emendation_state_to_withdrawn
        # rubocop:disable Rails/SkipsModelValidations
        @emendation.update_attribute :state, "withdrawn"
        # rubocop:enable Rails/SkipsModelValidations
      end
    end
  end
end
