# frozen_string_literal: true

module Decidim
  module Elections
    module Voter
      # This command allows the user to store and cast their vote.
      class CastVote < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form with necessary info to cast a vote.
        # bulletin_board_client - An instance of the bulletin board client to
        #                         send the vote to the Bulletin Board.
        def initialize(form, bulletin_board_client)
          @form = form
          @bulletin_board_client = bulletin_board_client
        end

        # Store and cast the vote
        #
        # Broadcasts :ok if successful, :invalid otherwise
        def call
          return broadcast(:invalid) unless form.valid?

          begin
            transaction do
              store_vote
              cast_vote_on_bulletin_board
              broadcast(:ok)
            end
          rescue StandardError
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form, :bulletin_board_client

        def cast_vote_on_bulletin_board
          bulletin_board_client.cast_vote(form.election_data, form.voter_data, form.encrypted_vote)
        end

        def store_vote
          Vote.create!(
            election: form.election,
            voter_id: form.voter_id,
            encrypted_vote_hash: form.encrypted_vote_hash,
            status: Vote::PENDING_STATUS
          )
        end
      end
    end
  end
end
