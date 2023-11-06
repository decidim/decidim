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

      def self.from_params(params)
        form = super(params)

        # not all questions are send via PATCH/POST if no nota is enabled so we need to
        # reconstruct the object and grab the user input value if exists
        form.question_results = form.election&.questions&.flat_map do |question|
          question_form = QuestionResultForm.from_model(question:, closure: form.closure)
          question_form.value = params.dig(:closure_result, :question_results, question.id.to_s, :value) ||
                                params.dig(:question_results, question.id.to_s, :value) || 0

          question_form
        end

        form
      end

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
        byebug
        # question_results.each do |question_form|
        #   next unless question_form.value > ballot_results.blank_ballots_count

        #   question_form.errors.add(:base, :blank_count_invalid)
        # end
      end
    end
  end
end
