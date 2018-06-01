# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This class holds a Form to update questionnaire question answer options
      class QuestionnaireAnswerOptionForm < Decidim::Form
        include TranslatableAttributes

        attribute :deleted, Boolean, default: false
        attribute :free_text, Boolean

        translatable_attribute :body, String

        validates :body, translatable_presence: true, unless: :deleted

        def to_param
          id || "questionnaire-question-answer-option-id"
        end
      end
    end
  end
end
