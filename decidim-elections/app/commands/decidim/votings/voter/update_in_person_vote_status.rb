# frozen_string_literal: true

module Decidim
  module Votings
    module Voter
      # This command updates the in person vote status
      class UpdateInPersonVoteStatus < Decidim::Command
        # Public: Initializes the command.
        #
        # in_person_vote     - the in person vote that has been updated
        def initialize(in_person_vote)
          @in_person_vote = in_person_vote
        end

        # Update status and send notification
        #
        # Broadcasts :ok if successful, :invalid otherwise
        def call
          return broadcast(:ok) unless status_changed?

          transaction do
            update_vote_status
          end

          broadcast(:ok)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :in_person_vote, :locale

        def status_changed?
          in_person_vote.status != vote_status
        end

        def bulletin_board
          @bulletin_board ||= Decidim::Elections.bulletin_board
        end

        def vote_status
          @vote_status ||= bulletin_board.get_pending_message_status(in_person_vote.message_id)
        end

        def update_vote_status
          in_person_vote.update!(status: vote_status)
        end
      end
    end
  end
end
