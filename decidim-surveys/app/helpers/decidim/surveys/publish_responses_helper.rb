# frozen_string_literal: true

module Decidim
  module Surveys
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

      private

      def sorting_stack_chart_wrapper(question)
        counts = Hash.new { |hash, key| hash[key] = Hash.new(0) }

        question.responses.each do |response|
          response.choices.each do |choice|
            name = translated_attribute(choice.response_option.body)
            row = choice.position + 1

            counts[row][name] += 1
          end
        end

        tally = counts.map do |name, row_data|
          {
            name:,
            data: row_data.map { |row, count| [row, count] }
          }
        end

        bar_chart(tally.sort_by { |data| data[:name] }, stacked: true, download: true)
      end

      def matrix_stack_chart_wrapper(question)
        counts = Hash.new { |hash, key| hash[key] = Hash.new(0) }

        question.responses.each do |response|
          response.choices.each do |choice|
            name = translated_attribute(choice.response_option.body)
            row = translated_attribute(choice.matrix_row.body)

            counts[name][row] += 1
          end
        end

        tally = counts.map do |name, row_data|
          {
            name:,
            data: row_data.map { |row, count| [row, count] }
          }
        end

        column_chart(tally, stacked: true, legend: :right, download: true)
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
