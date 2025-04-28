# frozen_string_literal: true

module Decidim
  module Demographics
    module PublishResponsesHelper
      def question_response_is_publicable(question_type)
        ignored_question_types = %w(short_response long_response separator files).freeze

        ignored_question_types.exclude?(question_type)
      end

      # Renders the chart for the given question.
      # Uses chartkick to render the chart.
      #
      # @param question_id [Integer] the question id for Decidim:
      def chart_for_question(question_id)
        question = Decidim::Forms::Question.includes(responses: { choices: [:response_option, :matrix_row] }).find(question_id)

        Chartkick.options = {
          library: { animation: { easing: "easeOutQuart" } },
          colors: colors_list
        }

        case question.question_type
        when "single_option", "multiple_option"
          options_column_chart_wrapper(question)
        when "matrix_single", "matrix_multiple"
          matrix_stack_chart_wrapper(question)
        when "sorting"
          sorting_stack_chart_wrapper(question)
        else
          "Unknown question type"
        end
      end

      def options_column_chart_wrapper(question)
        tally = question.responses.map { |response| response.choices.map { |choice| translated_attribute(choice.response_option.body) } }.tally

        column_chart(tally, download: true)
      end

      def colors_list
        %w(
          #3366CC
          #DC3912
          #FF9900
          #109618
          #3B3EAC
          #0099C6
          #DD4477
          #66AA00
          #B82E2E
          #316395
        )
      end
    end
  end
end
