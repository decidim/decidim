# frozen_string_literal: true

module Decidim
  module Elections
    module Voter
      # This command allows the user to store and cast their vote.
      class CastVote < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form with necessary info to cast a vote.
        def initialize(form)
          @form = form
        end

        # Store and cast the vote
        #
        # Broadcasts :ok if successful, :invalid otherwise
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            store_vote
            cast_vote_on_bulletin_board
          end

          broadcast(:ok, store_vote)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :form

        delegate :bulletin_board, to: :form

        def cast_vote_message_id
          bulletin_board.cast_vote_message_id(form.election_id, form.voter_id)
        end

        def cast_vote_on_bulletin_board
          bulletin_board.cast_vote(form.election_id, form.voter_id, form.encrypted_vote)
        end

        def user
          @user ||= form.current_organization.users.find_by(id: form.current_user)
        end

        def store_vote
          @store_vote ||= Vote.create!(
            message_id: cast_vote_message_id,
            election: form.election,
            voter_id: form.voter_id,
            encrypted_vote_hash: form.encrypted_vote_hash,
            status: :pending,
            user: user
          )
        end
      end
    end
  end
end
