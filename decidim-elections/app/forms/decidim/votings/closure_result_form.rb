# frozen_string_literal: true

module Decidim
  module Votings
    class ClosureResultForm < Decidim::Form
      attribute :id, Integer
      attribute :polling_station_id, Integer
      attribute :election_id, Integer

      attribute :ballot_results, BallotResultForm
      attribute :question_results, Array[QuestionResultForm]
      attribute :answer_results, Array[AnswerResultForm]

      validates :polling_station_id,
                :election_id,
                presence: true
      validate :max_answers_and_votes

      def map_model(model)
        self.id = model.id
        self.polling_station_id = model.polling_station.id
        self.election_id = model.election.id

        self.ballot_results = BallotResultForm.from_model(model)

        self.question_results = model.election.questions.flat_map do |question|
          QuestionResultForm.from_model(question:, closure: model)
        end

        self.answer_results = model.election.questions.flat_map do |question|
          question.answers.map do |answer|
            AnswerResultForm.from_model(answer:, closure: model)
          end
        end
      end

      # rubocop:disable Metrics/PerceivedComplexity
      # rubocop:disable Metrics/CyclomaticComplexity
      def self.from_params(params)
        form = super(params)

        # not all questions are send via PATCH/POST if no nota is enabled so we need to
        # reconstruct the object and grab the user input value if exists
        # It is necessary also to obtain the title of the question/answer
        form.question_results = form.election&.questions&.flat_map do |question|
          question_form = QuestionResultForm.from_model(question:, closure: form.closure)
          question_form.value = params.dig(:closure_result, :question_results, question.id.to_s, :value) ||
                                params.dig(:question_results, question.id.to_s, :value) || 0

          question_form
        end

        form.answer_results = form.election&.questions&.flat_map do |question|
          question.answers.map do |answer|
            answer_form = AnswerResultForm.from_model(answer:, closure: form.closure)
            answer_form.value = params.dig(:closure_result, :answer_results, answer.id.to_s, :value) ||
                                params.dig(:answer_results, answer.id.to_s, :value) || 0

            answer_form
          end
        end

        form
      end
      # rubocop:enable Metrics/PerceivedComplexity
      # rubocop:enable Metrics/CyclomaticComplexity

      def election
        @election ||= Decidim::Elections::Election.find_by(id: election_id)
      end

      def polling_station
        @polling_station ||= Decidim::Votings::PollingStation.find_by(id: polling_station_id)
      end

      def closure
        @closure ||= Decidim::Votings::PollingStationClosure.find_by(election:)
      end

      private

      def max_answers_and_votes
        expected_blanks = question_results.sum { |q| q.value.to_i }
        expected_answers = answer_results.sum { |a| a.value.to_i }
        if ballot_results.blank_ballots_count != expected_blanks
          ballot_results.errors.add(:blank_ballots_count, :invalid)
          errors.add(:base, I18n.t("decidim.votings.polling_officer_zone.closures.edit.modal_ballots_results_count_error.blank",
                                   expected: ballot_results.blank_ballots_count,
                                   current: expected_blanks))
        end
        if ballot_results.valid_ballots_count != expected_answers
          ballot_results.errors.add(:valid_ballots_count, :invalid)
          errors.add(:base, I18n.t("decidim.votings.polling_officer_zone.closures.edit.modal_ballots_results_count_error.valid",
                                   expected: ballot_results.valid_ballots_count,
                                   current: expected_answers))
        end
      end
    end
  end
end
