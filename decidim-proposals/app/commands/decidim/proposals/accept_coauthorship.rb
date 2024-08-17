# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user accepts an invitation to be a coauthor of a proposal.
    class AcceptCoauthorship < Decidim::Command
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

        begin
          transaction do
            @proposal.add_coauthor(@coauthor)
            @proposal.coauthor_invitations_for(@coauthor).destroy_all
          end

          generate_notifications
        rescue ActiveRecord::RecordInvalid
          return broadcast(:invalid)
        end

        broadcast(:ok)
      end

      private

      def generate_notifications
        # notify the author that the co-author has accepted the invitation
        Decidim::EventsManager.publish(
          event: "decidim.events.proposals.coauthor_accepted_invite",
          event_class: Decidim::Proposals::CoauthorAcceptedInviteEvent,
          resource: @proposal,
          affected_users: @proposal.authors.reject { |author| author == @coauthor },
          extra: { coauthor_id: @coauthor.id }
        )

        # notify the co-author of the new co-authorship
        Decidim::EventsManager.publish(
          event: "decidim.events.proposals.accepted_coauthorship",
          event_class: Decidim::Proposals::AcceptedCoauthorshipEvent,
          resource: @proposal,
          affected_users: [@coauthor]
        )
      end
    end
  end
end
