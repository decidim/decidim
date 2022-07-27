# frozen_string_literal: true

module Decidim
  module Votings
    module Voter
      # This command allows the user to register an in person vote.
      class InPersonVote < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form with necessary info to register an in person vote.
        def initialize(form)
          @form = form
        end

        # Store and register the in person vote in the bulletin board
        #
        # Broadcasts :ok if successful, :invalid otherwise
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            register_in_person_vote
          end

          broadcast(:ok, in_person_vote)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :form, :in_person_vote

        delegate :bulletin_board, to: :form

        def register_in_person_vote
          bulletin_board.in_person_vote(form.election_id, form.voter_id, form.polling_station_slug) do |message_id|
            create_in_person_vote(message_id)
          end
        end

        def create_in_person_vote(message_id)
          @in_person_vote = Decidim::Votings::InPersonVote.create!(
            election: form.election,
            polling_station: form.polling_station,
            polling_officer: form.polling_officer,
            message_id:,
            voter_id: form.voter_id,
            status: :pending
          )
        end
      end
    end
  end
end
