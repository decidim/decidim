# frozen_string_literal: true

module Decidim
  module Elections
    module Voter
      # This command allows the user to store and cast their vote.
      class CastVote < Decidim::Command
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
            cast_vote
          end

          broadcast(:ok, vote)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :form, :vote

        delegate :bulletin_board, to: :form

        def cast_vote
          bulletin_board.cast_vote(form.election_id, form.voter_id, form.encrypted_data) do |message_id|
            create_vote(message_id)
          end
        end

        def create_vote(message_id)
          @vote = Vote.create!(
            message_id:,
            election: form.election,
            voter_id: form.voter_id,
            encrypted_vote_hash: form.encrypted_data_hash,
            status: :pending,
            user: form.user,
            email: form.email
          )
        end
      end
    end
  end
end
