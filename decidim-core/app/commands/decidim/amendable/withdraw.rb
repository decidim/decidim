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
      # - :invalid if resource does not belong to the current user or already has supports.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless emendation.votes.empty? && amender == current_user

        transaction do
          withdraw_amendment!
          withdraw_emendation!
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

      # Unlike other Amendable commands, we need to update the state of the
      # emendation for the scope Decidim::Proposals::Proposal::expect_withdrawn
      # to be able to retrieve rejected emendations.
      #
      # Because we are modifying the emendation itself, we need to prevent
      # PaperTrail from creating an additional version to ensure that this
      # change does not appear in the diff renderer of the emendation page.
      def withdraw_emendation!
        PaperTrail.request(enabled: false) do
          emendation.update!(state: "withdrawn")
        end
      end
    end
  end
end
