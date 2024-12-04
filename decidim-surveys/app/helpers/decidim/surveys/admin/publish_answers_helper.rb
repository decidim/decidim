# frozen_string_literal: true

module Decidim
  module Surveys
    module Admin
      module PublishAnswersHelper
        # Renders the chart for the given question.
        # Uses chartkick to render the chart.
        #
        # @param question_id [Integer] the question id for Decidim:
        def chart_for_question(question_id)
          question = Decidim::Forms::Question.find(question_id)

          case question.question_type
          when "single_option"
            column_chart_wrapper(question)
          when "multiple_option"
            column_chart_wrapper(question)
          when "matrix_single"
            stack_chart_wrapper(question)
          when "matrix_multiple"
            stack_chart_wrapper(question)
          else
            "Unknown question type"
          end
        end

        private

        def stack_chart_wrapper(question)
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

        def column_chart_wrapper(question)
          tally = question.answers.map { |answer| answer.choices.map { |choice| translated_attribute(choice.answer_option.body) } }.tally


          column_chart(tally, dataset: { backgroundColor: colors_list, borderWidth: 0 })
        end

        def colors_list
          [
            'rgba(255, 99, 132, 0.2)',
            'rgba(255, 159, 64, 0.2)',
            'rgba(75, 192, 192, 0.2)',
            'rgba(54, 162, 235, 0.2)',
            'rgba(153, 102, 255, 0.2)',
            'rgba(255, 205, 86, 0.2)',
            'rgba(201, 203, 207, 0.2)'
          ]
        end
      end
    end
  end
end
