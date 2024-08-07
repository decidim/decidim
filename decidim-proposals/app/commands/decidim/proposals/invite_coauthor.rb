# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user invites a coauthor to a proposal
    class InviteCoauthor < Decidim::Command
      # Public: Initializes the command.
      #
      # proposal     - The proposal to add a coauthor to.
      # coauthor - The user to invite as coauthor.
      def initialize(proposal, coauthor)
        @proposal = proposal
        @coauthor = coauthor
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the proposal.
      # - :invalid if the coauthor is not valid.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless @coauthor
        return broadcast(:invalid) if @proposal.authors.include?(@coauthor)

        transaction do
          generate_notifications
        end

        broadcast(:ok)
      end

      private

      def generate_notifications
        Decidim::EventsManager.publish(
          event: "decidim.events.proposals.coauthor_invited",
          event_class: Decidim::Proposals::CoauthorInvitedEvent,
          resource: @proposal,
          affected_users: [@coauthor]
        )
      end
    end
  end
end
