# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This command gets called to start the tally in the Bulletin Board.
      class StartTally < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A VotePeriodForm object with the information needed to start or end the vote period
        def initialize(form)
          @form = form
        end

        # Public: Starts the tally for the Election.
        #
        # Broadcasts :ok if setup, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            log_action
            start_tally
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
            :start_tally,
            election,
            form.current_user,
            visibility: "all"
          )
        end

        def start_tally
          bulletin_board.start_tally(election.id) do |message_id|
            create_election_action(message_id)
          end
        end

        def create_election_action(message_id)
          Decidim::Elections::Action.create!(
            election: election,
            action: :start_tally,
            message_id: message_id,
            status: :pending
          )
        end
      end
    end
  end
end
