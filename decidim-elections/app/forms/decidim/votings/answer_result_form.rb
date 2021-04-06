# frozen_string_literal: true

module Decidim
  module Votings
    class AnswerResultForm < Decidim::Form
      attribute :id, Integer
      attribute :votes_count, Integer

      validates :id, :votes_count, presence: true
      validates :votes_count, numericality: true

      def map_model(model)
        answer = model[:answer]
        self.id = answer.id
        self.votes_count = Decidim::Elections::Result.find_by(answer: answer, polling_station: model[:polling_station])
      end
    end
  end
end
