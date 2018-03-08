# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user publishes a draft proposal.
    class PublishProposal < Rectify::Command
      # Public: Initializes the command.
      #
      # proposal     - The proposal to publish.
      # current_user - The current user.
      def initialize(proposal, current_user)
        @proposal = proposal
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid and the proposal is published.
      # - :invalid if the proposal's author is not the current user.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if @proposal.author != current_user

        @proposal.update published_at: Time.current

        broadcast(:ok, @proposal)
      end
    end
  end
end
