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

        def label_for_question(survey, _question)
          survey.questions_editable? ? "#{icon("move")} #{t(".question")}".html_safe : t(".question")
        end

        def mandatory_id_for_question(question)
          return "survey_questions_#{question.id}_mandatory" if question.persisted?
          "${tabsId}_mandatory"
        end

        def question_type_id_for_question(question)
          return "survey_questions_#{question.id}_question_type" if question.persisted?
          "${tabsId}_question_type"
        end

        def disabled_for_question(survey, question)
          !question.persisted? || !survey.questions_editable?
        end
      end
    end
  end
end
