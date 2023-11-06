# frozen_string_literal: true

module Decidim
  module Votings
    class QuestionResultForm < Decidim::Form
      include TranslatableAttributes

      attribute :id, Integer
      translatable_attribute :title, String
      attribute :nota_option, Boolean
      attribute :value, Integer

      validates :id, :value, presence: true
      validates :value, numericality: true

      validate :max_blank_count

      def map_model(model)
        @question = model[:question]
        @closure = model[:closure]
        self.id = question.id
        self.title = question.title
        self.nota_option = question.nota_option?
        self.value = closure&.results&.blank_answers&.find_by(question:)&.value
      end

      def question
        @question ||= Decidim::Elections::Question.find_by(id:)
      end

      def closure
        @closure ||= context&.closure
      end

      private

      def max_blank_count
        return unless value.to_i > closure&.results&.blank_ballots&.first&.value.to_i

        errors.add(:base, :blank_count_invalid)
      end
    end
  end
end
