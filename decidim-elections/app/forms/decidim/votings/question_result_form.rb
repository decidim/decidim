# frozen_string_literal: true

module Decidim
  module Votings
    class QuestionResultForm < Decidim::Form
      include TranslatableAttributes

      attribute :id, Integer
      translatable_attribute :title, String
      attribute :nota_option, Boolean
      attribute :votes_count, Integer

      validates :id, :votes_count, presence: true
      validates :votes_count, numericality: true

      def map_model(model)
        question = model[:question]
        self.id = question.id
        self.title = question.title
        self.nota_option = question.nota_option?
        self.votes_count = Decidim::Elections::Result.find_by(question: question, polling_station: model[:polling_station])&.votes_count.to_i
      end
    end
  end
end
