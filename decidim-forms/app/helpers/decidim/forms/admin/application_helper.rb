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

        def tabs_id_for_question_display_condition(question, display_condition)
          "questionnaire_question_#{question.to_param}_display_condition_#{display_condition.to_param}"
        end

        def tabs_id_for_question_matrix_row(question, matrix_row)
          "questionnaire_question_#{question.to_param}_matrix_row_#{matrix_row.to_param}"
        end

        def dynamic_title(title, **options)
          data = {
            "max-length" => options[:max_length],
            "omission" => options[:omission],
            "placeholder" => options[:placeholder],
            "locale" => I18n.locale
          }
          content_tag :span, class: options[:class], data: data do
            truncate translated_attribute(title), length: options[:max_length], omission: options[:omission]
          end
        end
      end
    end
  end
end
