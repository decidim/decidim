# frozen_string_literal: true
module Decidim
  module Surveys
    module Admin
      # This class holds a Form to update surveys from Decidim's admin panel.
      class SurveyForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :description, String
        translatable_attribute :toc, String
        attribute :published_at, DateTime

        attribute :questions, Array[SurveyQuestionForm]

        # # Private: Sort the questions by its position
        # #
        # # Returns nothing.
        # def map_model(model)
        #   self.questions = model.questions.order('position').map do |survey_question|
        #     SurveyQuestionForm.from_model(survey_question)
        #   end
        # end
      end
    end
  end
end
