# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # This command gets called when a voting is unpublished from the admin panel.
      class UnpublishVoting < Decidim::Command
        # Public: Initializes the command.
        #
        # voting - The voting to unpublish.
        # current_user - the user performing the action
        def initialize(voting, current_user)
          @voting = voting
          @current_user = current_user
        end

        # Public: Unpublishes the Voting.
        #
        # Broadcasts :ok if unpublished, :invalid otherwise.
        def call
          return broadcast(:invalid) if voting.nil? || !voting.published?

          unpublish_voting

          broadcast(:ok, voting)
        end

        private

        attr_reader :voting, :current_user

        def unpublish_voting
          Decidim.traceability.perform_action!(:unpublish, voting, current_user, visibility: "all") do
            voting.unpublish!
          end
        end
      end
    end
  end
end
