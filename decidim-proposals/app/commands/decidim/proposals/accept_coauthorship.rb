# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user withdraws a new proposal.
    class AcceptCoauthorship < Decidim::Command
      # Public: Initializes the command.
      #
      # proposal     - The proposal to add a coauthor to.
      # coauthor - The user to invite as coauthor.
      # notification - The notification that triggered the command.
      def initialize(proposal, coauthor, notification)
        @proposal = proposal
        @coauthor = coauthor
        @notification = notification
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the proposal.
      # - :has_votes if the proposal already has votes or does not belong to current user.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless @coauthor
        return broadcast(:invalid) if @proposal.authors.include?(@coauthor)

        extra = @notification.extra
        extra.delete("uuid")
        extra.delete("coauthor_id")
        transaction do
          @proposal.add_coauthor(@coauthor)
          @notification.update_column(:extra, extra)
        end

        broadcast(:ok)
      end
    end
  end
end
