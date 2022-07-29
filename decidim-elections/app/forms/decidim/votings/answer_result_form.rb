# frozen_string_literal: true

module Decidim
  module Votings
    class AnswerResultForm < Decidim::Form
      include TranslatableAttributes

      attribute :id, Integer
      translatable_attribute :title, String
      attribute :question_id, Integer
      attribute :value, Integer

      validates :id, :question_id, :value, presence: true
      validates :value, numericality: true

      def map_model(model)
        answer = model[:answer]
        closure = model[:closure]
        self.id = answer.id
        self.title = answer.title
        self.question_id = answer.question.id
        self.value = closure.results&.valid_answers&.find_by(answer: answer)&.value
      end
    end
  end
end
