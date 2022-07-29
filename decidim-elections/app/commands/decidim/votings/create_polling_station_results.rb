# frozen_string_literal: true

module Decidim
  module Votings
    # A command with all the business logic when creating results for a polling station
    class CreatePollingStationResults < Decidim::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      # closure - A closure object.
      def initialize(form, closure)
        @form = form
        @closure = closure
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
          closure.results.not_total_ballots.destroy_all

          form.ballot_results.attributes.compact.each do |ballot_result|
            create_ballot_result_for!(ballot_result)
          end

          form.answer_results.each do |answer_result|
            create_answer_result_for!(answer_result)
          end

          form.question_results.each do |question_result|
            create_question_result_for!(question_result)
          end

          closure.certificate_phase!
        end

        broadcast(:ok)
      end

      private

      attr_reader :form, :closure

      def create_ballot_result_for!(ballot_results)
        params = {
          value: ballot_results.last,
          result_type: ballot_results.first.to_s.remove("_count")
        }

        create_result!(params)
      end

      def create_answer_result_for!(answer_result)
        params = {
          value: answer_result.value,
          decidim_elections_question_id: answer_result.question_id,
          decidim_elections_answer_id: answer_result.id,
          result_type: :valid_answers
        }

        create_result!(params)
      end

      def create_question_result_for!(question_result)
        params = {
          value: question_result.value,
          decidim_elections_question_id: question_result.id,
          result_type: :blank_answers
        }

        create_result!(params)
      end

      def create_result!(params)
        closure.results.create!(params)
      end
    end
  end
end
