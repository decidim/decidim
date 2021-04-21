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

      def map_model(model)
        question = model[:question]
        self.id = question.id
        self.title = question.title
        self.nota_option = question.nota_option?
      end
    end
  end
end
