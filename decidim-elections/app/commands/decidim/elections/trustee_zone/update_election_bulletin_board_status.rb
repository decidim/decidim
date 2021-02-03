# frozen_string_literal: true

module Decidim
  module Elections
    module TrusteeZone
      # This command updates the election status if it got changed
      class UpdateElectionBulletinBoardStatus < Rectify::Command
        # Public: Initializes the command.
        #
        # status - The actual election status
        def initialize(election, required_status)
          @election = election
          @required_status = required_status
        end

        # Update the election if status got changed.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:ok, election) if election.bb_status.to_sym != required_status.to_sym

          transaction do
            update_election_status!
            fetch_election_results if election.bb_tally_ended?
          end

          broadcast(:ok, election)
        end

        private

        attr_reader :election, :required_status

        def decoded_data
          @decoded_data ||= begin
            signed_data = Decidim::Elections.bulletin_board.get_election_log_entries_by_types(election.id, ["end_tally"])
            public_key = Rails.application.secrets.bulletin_board[:server_public_key]
            public_key_rsa = JWT::JWK::RSA.import(public_key).public_key
            JWT.decode(signed_data.first.signed_data, public_key_rsa, true, algorithm: "RS256")
          rescue JWT::VerificationError, JWT::DecodeError, JWT::InvalidIatError, JWT::InvalidPayload => e
            { error: e.message }
          end
        end

        def results
          @results ||= decoded_data.first["results"]
        end

        def fetch_election_results
          answers = []
          results.values.map do |values|
            values.each do |key, value|
              answers = Decidim::Elections::Answer.where(id: key)
              answers.each do |answer|
                answer.votes_count = value
                answer.save!
              end
            end
          end
        end

        def update_election_status!
          status = Decidim::Elections.bulletin_board.get_election_status(election.id)
          election.bb_status = status
          election.save!
        end
      end
    end
  end
end
