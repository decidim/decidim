# frozen_string_literal: true

module Decidim
  module Surveys
    module Admin
      # Custom helpers, scoped to the surveys engine.
      #
      module ApplicationHelper
        def tabs_id_for_question(question)
          return "survey-question-#{question.id}" if question.persisted?
          "${tabsId}"
        end

        def tabs_id_for_question_answer_option(question, idx)
          return "survey-question-answer-option-#{question.id}-#{idx}" if question.present?
          "${tabsId}"
        end

        def mandatory_id_for_question(question)
          question_attribute_id(question, "mandatory")
        end

        def question_type_id_for_question(question)
          question_attribute_id(question, "question_type")
        end

        private

        def question_attribute_id(question, attribute)
          return "survey_questions_#{question.id}_#{attribute}" if question.persisted?
          "${tabsId}_#{attribute}"
        end
      end
    end
  end
end
