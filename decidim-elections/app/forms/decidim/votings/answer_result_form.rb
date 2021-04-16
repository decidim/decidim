# frozen_string_literal: true

module Decidim
  module Votings
    class AnswerResultForm < Decidim::Form
      include TranslatableAttributes

      attribute :id, Integer
      translatable_attribute :title, String
      attribute :question_id, Integer
      attribute :votes_count, Integer

      validates :id, :question_id, :votes_count, presence: true
      validates :votes_count, numericality: true

      def map_model(model)
        answer = model[:answer]
        self.id = answer.id
        self.title = answer.title
        self.question_id = answer.question.id
        # self.votes_count = model[:closure].results.valid_answers.find_by(answer: answer)&.votes_count.to_i
      end
    end
  end
end
