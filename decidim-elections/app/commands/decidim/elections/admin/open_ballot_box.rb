# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This command gets called to open the ballot box in the Bulletin Board.
      class OpenBallotBox < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A BallotBoxForm object with the information needed to open or close the ballot box
        def initialize(form)
          @form = form
        end

        # Public: Open the ballot box for the Election.
        #
        # Broadcasts :ok if setup, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            log_action
            open_ballot_box
          end

          broadcast(:ok)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_accessor :form

        delegate :election, :bulletin_board, to: :form

        def log_action
          Decidim.traceability.perform_action!(
            :open_ballot_box,
            election,
            form.current_user,
            visibility: "all"
          )
        end

        def open_ballot_box
          bb_election = bulletin_board.open_ballot_box(election.id)
          store_bulletin_board_status(bb_election.status)
        rescue StandardError => e
          broadcast(:invalid, e.message)
          raise ActiveRecord::Rollback
        end

        def store_bulletin_board_status(bb_status)
          election.bb_status = bb_status
          election.save
        end
      end
    end
  end
end
