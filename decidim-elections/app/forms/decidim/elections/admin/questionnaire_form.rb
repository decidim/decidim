# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      class QuestionnaireForm < Decidim::Form
        attribute :questions, Array[Decidim::Elections::Admin::QuestionForm]

        def map_model(model)
          self.questions = model.questions.map do |question|
            Decidim::Elections::Admin::QuestionForm.from_model(question)
          end
        end
      end
    end
  end
end
