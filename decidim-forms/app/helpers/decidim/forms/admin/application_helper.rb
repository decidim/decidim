# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
      # Custom helpers, scoped to the forms engine.
      #
      module ApplicationHelper
        def tabs_id_for_question(question)
          "questionnaire_question_#{question.to_param}"
        end

        def tabs_id_for_question_answer_option(question, answer_option)
          "questionnaire_question_#{question.to_param}_answer_option_#{answer_option.to_param}"
        end
  
        # TODO: Should we move this to new helper?
        def questionnaire_answer_body(answer)
          return answer.body if answer.body.present?
  
          choices = answer.choices.map do |choice|
            choice.try(:custom_body) || choice.try(:body)
          end
  
          choices.join(", ") # TODO: is this separator defined as a locale or similar?
        end
  
        def questionnaire_answer_user_status(answer)
          answer.decidim_user_id.present? ? "registered" : "unregistered" # TODO: translate
        end
  
        def questionnaire_answer_session_token_mask(answer)
          token = answer.session_token
          [token[0..1], token[-2..-1]].join("...")
        end
      end
    end
  end
end
