# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user rejects and invitation to be a proposal co-author
    class RejectCoauthorship < Decidim::Command
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

        @proposal.coauthor_invitations_for(@coauthor).destroy_all
        generate_notifications

        broadcast(:ok)
      end

      private

      def generate_notifications
        # notify the author that the co-author has rejected the invitation
        Decidim::EventsManager.publish(
          event: "decidim.events.proposals.coauthor_rejected_invite",
          event_class: Decidim::Proposals::CoauthorRejectedInviteEvent,
          resource: @proposal,
          affected_users: @proposal.authors,
          extra: { coauthor_id: @coauthor.id }
        )

        # notify the co-author of his own decision
        Decidim::EventsManager.publish(
          event: "decidim.events.proposals.rejected_coauthorship",
          event_class: Decidim::Proposals::RejectedCoauthorshipEvent,
          resource: @proposal,
          affected_users: [@coauthor]
        )
      end
    end
  end
end
