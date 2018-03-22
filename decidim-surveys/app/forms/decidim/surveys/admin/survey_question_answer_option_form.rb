# frozen_string_literal: true

module Decidim
  module Surveys
    module Admin
      # This class holds a Form to update survey question answer options
      class SurveyQuestionAnswerOptionForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :body, String

        validates :body, translatable_presence: true

        def to_param
          id || "survey-question-answer-option-id"
        end
      end
    end
  end
end
