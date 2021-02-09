# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This command gets called to publish the election results in the Bulletin Board.
      class PublishResults < Rectify::Command
        # Public: Initializes the command.
        #
        # form - An ActionForm object with the information needed to publish the results
        def initialize(form)
          @form = form
        end

        # Public: Publish the results for the Election.
        #
        # Broadcasts :ok if setup, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            log_action
            update_election
            publish_results
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
            :publish_results,
            election,
            form.current_user,
            visibility: "all"
          )
        end

        def publish_results
          bb_election = bulletin_board.publish_results(election.id)

          raise StandardError, "Wrong status for the election with published results" if bb_election.status != "results_published"
        end

        def update_election
          election.bb_results_published!
        end
      end
    end
  end
end
