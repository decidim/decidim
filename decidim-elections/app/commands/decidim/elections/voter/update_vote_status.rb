# frozen_string_literal: true

module Decidim
  module Elections
    module Voter
      # This command updates the vote status and sends a notification.
      class UpdateVoteStatus < Decidim::Command
        # Public: Initializes the command.
        #
        # vote        - the vote that has been updated
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
            notify_voter
          end

          broadcast(:ok)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :vote, :locale

        def verify_url
          @verify_url ||= Decidim::EngineRouter.main_proxy(vote.election.component).election_vote_verify_url(vote.election, vote_id: vote.encrypted_vote_hash)
        end

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
          vote.update!(status: vote_status)
        end

        def notify_voter
          return unless vote.accepted?

          if vote.user
            send_vote_notification
          elsif vote.email
            send_vote_email
          end
        end

        def send_vote_notification
          data = {
            event: "decidim.events.elections.votes.accepted_votes",
            event_class: Decidim::Elections::Votes::VoteAcceptedEvent,
            resource: vote.election,
            affected_users: [vote.user],
            extra: {
              vote: vote,
              verify_url: verify_url
            }
          }

          Decidim::EventsManager.publish(**data)
        end

        def send_vote_email
          Decidim::Elections::VoteAcceptedMailer.notification(vote, verify_url, I18n.locale.to_s).deliver_later
        end
      end
    end
  end
end
