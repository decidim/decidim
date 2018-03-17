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

        def tabs_id_for_question_answer_option(answer_option, idx)
          return "survey-question-answer-option-#{answer_option.question.id}-#{idx}" if answer_option.persisted?
          "${tabsId}"
        end
      end
    end
  end
end
