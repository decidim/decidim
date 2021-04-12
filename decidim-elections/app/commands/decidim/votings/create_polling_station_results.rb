# frozen_string_literal: true

module Decidim
  module Votings
    # A command with all the business logic when creating results for a polling station
    class CreatePollingStationResults < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      # polling_officer - A polling_officer.
      def initialize(form, polling_officer)
        @form = form
        @polling_officer = polling_officer
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        transaction do
          form.ballot_results.attributes.each do |ballot_result|
            create_ballot_result_for!(ballot_result)
          end

          form.answer_results.each do |answer_result|
            create_answer_result_for!(answer_result)
          end

          form.question_results.each do |question_result|
            create_question_result_for!(question_result)
          end
        end

        broadcast(:ok)
      end

      private

      attr_reader :form, :polling_officer

      def create_ballot_result_for!(ballot_results)
        params = {
          decidim_votings_polling_station_id: form.polling_station_id,
          decidim_elections_election_id: form.election_id,
          votes_count: ballot_results.last,
          result_type: ballot_results.first.to_s.remove("_count")
        }

        create_result!(params)
      end

      def create_answer_result_for!(answer_result)
        params = {
          decidim_votings_polling_station_id: form.polling_station_id,
          decidim_elections_election_id: form.election_id,
          votes_count: answer_result.votes_count,
          decidim_elections_question_id: answer_result.question_id,
          decidim_elections_answer_id: answer_result.id,
          result_type: "valid_answers"
        }

        create_result!(params)
      end

      def create_question_result_for!(question_result)
        params = {
          decidim_votings_polling_station_id: form.polling_station_id,
          decidim_elections_election_id: form.election_id,
          votes_count: question_result.votes_count,
          decidim_elections_question_id: question_result.id,
          result_type: "blank_answers"
        }

        create_result!(params)
      end

      def create_result!(params)
        Decidim.traceability.create!(
          Decidim::Elections::Result,
          polling_officer.user,
          params,
          visibility: "admin-only"
        )
      end
    end
  end
end
