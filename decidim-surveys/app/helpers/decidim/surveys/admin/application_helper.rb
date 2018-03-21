# frozen_string_literal: true

module Decidim
  module Surveys
    module Admin
      # Custom helpers, scoped to the surveys engine.
      #
      module ApplicationHelper
        def tabs_id_for_question(question)
          "survey_question_#{question.to_param}"
        end

        def tabs_id_for_question_answer_option(question, answer_option)
          "survey_question_#{question.to_param}_answer_option_#{answer_option.to_param}"
        end
      end
    end
  end
end
