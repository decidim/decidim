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

        def results
          @results ||= Decidim::Elections.bulletin_board.get_election_results(election.id)
        end

        def fetch_election_results
          answers = []
          results.values.map do |values|
            values.each do |key, value|
              result_key = get_answer_id_from_result(key)
              answers = Decidim::Elections::Answer.where(id: result_key)
              answers.each do |answer|
                answer.votes_count = value
                answer.save!
              end
            end
          end
        end

        def get_answer_id_from_result(result_key)
          result_key.match(/question-\d+_answer-(\d+)/).captures
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
