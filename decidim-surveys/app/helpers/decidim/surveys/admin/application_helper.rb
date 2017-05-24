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

        def label_for_question(survey, question)
          return survey.published? ? t('.question') : "#{icon("move")} #{t('.question')}".html_safe if question.persisted?
          "#{icon("move")} #{t('.question')} #${questionLabelPosition}".html_safe
        end

        def mandatory_id_for_question(question)
          return "survey_questions_#{question.id}_mandatory" if question.persisted?
          "${tabsId}_mandatory"
        end

        def position_for_question(question)
          return question.position if question.persisted?
          "${position}"
        end

        def disabled_for_question(survey, question)
          !question.persisted? || survey.published?
        end
      end
    end
  end
end
