# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
      # This class holds a Form to update questionnaires questions from Decidim's admin panel.
      class QuestionsForm < Decidim::Form
        attribute :published_at, Decidim::Attributes::TimeWithZone
        attribute :questions, Array[QuestionForm]

        def map_model(model)
          self.questions = model.questions.map do |question|
            QuestionForm.from_model(question)
          end
        end
      end
    end
  end
end
