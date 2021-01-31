# frozen_string_literal: true

module Decidim
  module Elections
    module Voter
      # This command updates the vote status and sends a notification.
      class UpdateVoteStatus < Rectify::Command
        # Public: Initializes the command.
        #
        # message_id - the message_id to find a pending_message that is related to a vote.
        def initialize(vote)
          @vote = vote
        end

        # Update status and send notification
        #
        # Broadcasts :ok if successful, :invalid otherwise
        def call
          return broadcast(:ok) unless status_changed?

          transaction do
            update_vote_status
            send_vote_notification
          end

          broadcast(:ok)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :vote

        def status_changed?
          vote.status != vote_status
        end

        def bulletin_board
          @bulletin_board ||= Decidim::Elections.bulletin_board
        end

        def vote_status
          @vote_status ||= bulletin_board.get_pending_message_status(vote.message_id)
        end

        def update_vote_status
          vote.status = vote_status
          vote.save!
        end

        def send_vote_notification
          return unless vote.accepted?

          data = {
            event: "decidim.events.elections.votes.accepted_votes",
            event_class: Decidim::Elections::Votes::VoteAcceptedEvent,
            resource: vote.election,
            affected_users: [vote.user],
            extra: {
              vote: vote
            }
          }

          Decidim::EventsManager.publish(data)
        end
      end
    end
  end
end
