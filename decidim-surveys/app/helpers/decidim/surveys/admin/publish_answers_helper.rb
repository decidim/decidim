# frozen_string_literal: true

module Decidim
  module Surveys
    module Admin
      module PublishAnswersHelper
        # Renders the chart for the given question.
        # Uses chartkick to render the chart.
        #
        # @param question_id [Integer] the question id for Decidim::Fomrs::Question
        def chart_for_question(question_id)
          question = Decidim::Forms::Question.find(question_id)

          case question.question_type
          when "single_option"
            chart_for_single_option(question)
          when "multiple_option"
            chart_for_single_option(question)
          when "matrix_single"
            "TBI"
          when "matrix_multiple"
            "TBI"
          else
            "Unknown question type"
          end
        end

        private

        def chart_for_single_option(question)
          tally = question.answer_options.map { |option| translated_attribute(option.body) }.tally

          # column_chart tally
          pie_chart tally
        end
      end
    end
  end
end
