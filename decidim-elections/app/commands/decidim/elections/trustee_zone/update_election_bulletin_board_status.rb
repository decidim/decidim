# frozen_string_literal: true

module Decidim
  module Elections
    module TrusteeZone
      # This command updates the election status if it got changed
      class UpdateElectionBulletinBoardStatus < Decidim::Command
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
            election.create_bb_closure!
            update_election_status!

            if election.bb_tally_ended?
              fetch_election_results
              store_verifiable_results
            end
          end

          broadcast(:ok, election)
        end

        private

        attr_reader :election, :required_status

        def results
          @results ||= Decidim::Elections.bulletin_board.get_election_results(election.id)
        end

        def election_results
          results[:election_results]
        end

        def verifiable_results
          results[:verifiable_results]
        end

        def fetch_election_results
          answers = []
          election_results.values.map do |values|
            values.each do |key, value|
              result_key = get_answer_id_from_result(key)
              answers = Decidim::Elections::Answer.where(id: result_key)
              answers.each do |answer|
                create_answer_result_for!(answer, value)
              end
            end
          end
        end

        def create_answer_result_for!(answer, value)
          params = {
            value:,
            question: answer.question,
            answer:,
            result_type: :valid_answers
          }

          election.bb_closure.results.create!(params)
        end

        def get_answer_id_from_result(result_key)
          result_key.match(/question-\d+_answer-(\d+)/).captures
        end

        def store_verifiable_results
          election.update!(
            verifiable_results_file_url:,
            verifiable_results_file_hash: verifiable_results[:hash]
          )
        end

        def verifiable_results_file_url
          URI.join(Decidim::Elections.bulletin_board.bulletin_board_server, verifiable_results[:url])
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
