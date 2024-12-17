# frozen_string_literal: true

module Decidim
  module Surveys
    module Admin
      module PublishAnswersHelper

        def question_answer_is_publicable(question_type)
          ignored_question_types = %w(short_answer long_answer separator files).freeze

          ignored_question_types.exclude?(question_type)
        end

        # Renders the chart for the given question.
        # Uses chartkick to render the chart.
        #
        # @param question_id [Integer] the question id for Decidim:
        def chart_for_question(question_id)
          question = Decidim::Forms::Question.includes(answers: { choices: [ :answer_option, :matrix_row ] }).find(question_id)

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
          tally = []
          counts = Hash.new { |hash, key| hash[key] = Hash.new(0) }

          question.answers.each do |answer|
            answer.choices.each do |choice|
              name = translated_attribute(choice.answer_option.body)
              row = choice.position + 1

              counts[row][name] += 1
            end
          end

          tally = counts.map do |name, row_data|
            {
              name: name,
              data: row_data.map { |row, count| [row, count] }
            }
          end

          bar_chart tally.sort_by { |data| data[:name] }, stacked: true, colors: colors_list
        end

        def matrix_stack_chart_wrapper(question)
          tally = []
          counts = Hash.new { |hash, key| hash[key] = Hash.new(0) }

          question.answers.each do |answer|
            answer.choices.each do |choice|
              name = translated_attribute(choice.answer_option.body)
              row = translated_attribute(choice.matrix_row.body)

              counts[name][row] += 1
            end
          end

          tally = counts.map do |name, row_data|
            {
              name: name,
              data: row_data.map { |row, count| [row, count] }
            }
          end

          column_chart tally, stacked: true, colors: colors_list
        end

        def options_column_chart_wrapper(question)
          tally = question.answers.map { |answer| answer.choices.map { |choice| translated_attribute(choice.answer_option.body) } }.tally


          column_chart(tally, dataset: { backgroundColor: colors_list, borderWidth: 0 })
        end

        def colors_list
          [
            'rgba(255, 99, 132, 0.4)',
            'rgba(255, 159, 64, 0.4)',
            'rgba(75, 192, 192, 0.4)',
            'rgba(54, 162, 235, 0.4)',
            'rgba(153, 102, 255, 0.4)',
            'rgba(255, 205, 86, 0.4)',
            'rgba(201, 203, 207, 0.4)'
          ]
        end
      end
    end
  end
end
