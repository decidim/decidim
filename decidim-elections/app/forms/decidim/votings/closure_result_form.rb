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
    end
  end
end
