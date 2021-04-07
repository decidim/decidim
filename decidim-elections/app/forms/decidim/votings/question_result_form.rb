# frozen_string_literal: true

module Decidim
  module Votings
    class QuestionResultForm < Decidim::Form
      attribute :id, Integer
      attribute :votes_count, Integer

      validates :id, :votes_count, presence: true
      validates :votes_count, numericality: true

      def map_model(model)
        question = model[:question]
        self.id = question.id
        self.votes_count = Decidim::Elections::Result.find_by(question: question, polling_station: model[:polling_station])
      end
    end
  end
end
