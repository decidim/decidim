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
        attribute :options, Array[SurveyQuestionAnswerOptionForm]
        attribute :deleted, Boolean, default: false

        translatable_attribute :body, String

        validates :position, numericality: { greater_than_or_equal_to: 0 }
        validates :question_type, inclusion: { in: SurveyQuestion::TYPES }
        validates :body, translatable_presence: true, unless: :deleted

        def map_model(model)
          self.options = model.answer_options
        end

        def options=(value)
          @options = value.map do |option|
            SurveyQuestionAnswerOptionForm.new(option)
          end
        end
      end
    end
  end
end
