# frozen_string_literal: true

module Decidim
  module Surveys
    module Admin
      # This class holds a Form to update survey questions from Decidim's admin panel.
      class SurveyQuestionForm < Decidim::Form
        include TranslatableAttributes

        attribute :position, Integer
        attribute :mandatory, Boolean, default: false
        attribute :question_type, String
        attribute :answer_options, Array[SurveyAnswerOptionForm]
        attribute :max_choices, Integer
        attribute :deleted, Boolean, default: false

        translatable_attribute :body, String
        translatable_attribute :description, String

        validates :position, numericality: { greater_than_or_equal_to: 0 }
        validates :question_type, inclusion: { in: SurveyQuestion::TYPES }
        validates :max_choices, numericality: { only_integer: true, greater_than: 1, less_than_or_equal_to: ->(form) { form.number_of_options } }, allow_blank: true
        validates :body, translatable_presence: true, unless: :deleted

        def to_param
          id || "survey-question-id"
        end

        def number_of_options
          answer_options.size
        end
      end
    end
  end
end
