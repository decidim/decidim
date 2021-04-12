# frozen_string_literal: true

module Decidim
  module Votings
    class ElectionResultForm < Decidim::Form
      attribute :polling_station_id, Integer
      attribute :election_id, Integer

      attribute :ballot_results, BallotResultForm
      attribute :question_results, Array[QuestionResultForm]
      attribute :answer_results, Array[AnswerResultForm]

      validates :polling_station_id,
                :election_id,
                presence: true

      def map_model(model)
        self.polling_station_id = model.polling_station.id
        self.election_id = model.election.id

        self.ballot_results = BallotResultForm.from_model(election: model.election, polling_station: model.polling_station)

        self.question_results = model.election.questions.flat_map do |question|
          QuestionResultForm.from_model(question: question, polling_station: model.polling_station)
        end

        self.answer_results = model.election.questions.flat_map do |question|
          question.answers.map do |answer|
            AnswerResultForm.from_model(answer: answer, polling_station: model.polling_station)
          end
        end
      end
    end
  end
end
