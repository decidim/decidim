# frozen_string_literal: true
module Decidim
  module Surveys
    module Admin
      # This class holds a Form to update survey questions from Decidim's admin panel.
      class SurveyQuestionForm < Decidim::Form
        include TranslatableAttributes

        attribute :id, String
        attribute :position, Integer
        attribute :mandatory, Boolean, default: false
        attribute :question_type, String

        attribute :deleted, Boolean, default: false

        translatable_attribute :body, String

        validates :position, numericality: { greater_than_or_equal_to: 0 }
        validates :question_type, inclusion: { in: SurveyQuestion::TYPES }
      end
    end
  end
end
