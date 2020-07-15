# frozen_string_literal: true

module Decidim
  module Amendable
    # A command with all the business logic to withdraw an amendment.
    class Withdraw < Rectify::Command
      # Public: Initializes the command.
      #
      # amendment     - The amendment to withdraw.
      # current_user  - The current user.
      def initialize(amendment, current_user)
        @amendment = amendment
        @amender = amendment.amender
        @current_user = current_user
        @emendation = amendment.emendation
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the resource.
      # - :invalid if the resource already has supports or does not belong to current user.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless emendation.votes.empty? && amender == current_user

        transaction do
          withdraw_amendment!
          notify_emendation_state_change!
        end

        broadcast(:ok, emendation)
      end

      private

      attr_reader :amendment, :amender, :current_user, :emendation

      def withdraw_amendment!
        @amendment = Decidim.traceability.update!(
          amendment,
          current_user,
          { state: "withdrawn" },
          visibility: "public-only"
        )
      end

      def notify_emendation_state_change!
        emendation.process_amendment_state_change!
      end
    end
  end
end
