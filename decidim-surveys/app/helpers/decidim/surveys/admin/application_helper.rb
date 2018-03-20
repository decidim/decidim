# frozen_string_literal: true

module Decidim
  module Surveys
    module Admin
      # Custom helpers, scoped to the surveys engine.
      #
      module ApplicationHelper
        def tabs_id_for_question(question)
          id = question.persisted? ? question.id : "id"

          "survey_question_#{id}"
        end

        def tabs_id_for_question_answer_option(answer_option, idx)
          id = answer_option.persisted? ? "#{answer_option.question.id}-#{idx}" : "id"

          "survey_question_answer_option_#{id}"
        end
      end
    end
  end
end
