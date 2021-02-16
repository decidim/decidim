# frozen_string_literal: true

module Decidim
  module Elections
    module TrusteeZone
      # This command updates the election status if it got changed
      class UpdateElectionBulletinBoardStatus < Rectify::Command
        # Public: Initializes the command.
        #
        # status - The actual election status
        def initialize(election, required_status)
          @election = election
          @required_status = required_status
        end

        # Update the election if status got changed.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:ok, election) unless election.bb_status.to_sym == required_status.to_sym

          update_election_status!

          broadcast(:ok, election)
        end

        private

        attr_reader :election, :required_status

        def update_election_status!
          status = Decidim::Elections.bulletin_board.get_election_status(election.id)
          election.bb_status = status
          election.save!
        end
      end
    end
  end
end
