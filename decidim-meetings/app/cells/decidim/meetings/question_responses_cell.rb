# frozen_string_literal: true

module Decidim
  module Meetings
    # This cell renders the percentage of responses which chose
    # the given answer option in a meeting poll question
    class QuestionResponsesCell < Decidim::ViewModel
      include ActionView::Helpers::NumberHelper

      def show
        render
      end

      private

      # Returns an array of arrays, where the internal array contains
      #   - the body of the answer option
      #   - the percentage of answers for that option
      #
      def answer_options_with_percentages
        # This query joins answer options with answer choices and answers
        # and returns for each answer option the count of times it has been answered
        # grouping by answer options and answers.
        #
        # This calculation is a bit complex because of multiple option answers
        question_answers_choices = Decidim::Meetings::AnswerOption.where(decidim_question_id: model.id)
                                                                  .joins([choices: :answer])
                                                                  .group(Arel.sql("#{answers_table_name}.id, #{answer_options_table_name}.id"))
                                                                  .select(<<~SELECT
                                                                    #{answer_options_table_name}.id AS id,
                                                                    #{answer_options_table_name}.body,
                                                                    #{answers_table_name}.id AS answer_id,
                                                                    COUNT(decidim_answer_option_id) AS count
                                                                  SELECT
                                                                         )

        # Extract the number of uniq answers by the answer_id attribute
        total_answers = question_answers_choices.map(&:answer_id).compact.uniq.size

        # A second grouping is necessary to count the number of answers for each answer_option id
        # and calculate the percentages
        options_with_percentages = []
        question_answers_choices.group_by(&:id).each do |_id, values|
          answers_count = values.sum(&:count)
          options_with_percentages << [values.first.body, calculate_and_format_percentage(answers_count, total_answers)]
        end

        options_with_percentages
      end

      def format_percentage(raw_percentage)
        "#{number_with_precision(raw_percentage, precision: 2, significant: true)}%"
      end

      def calculate_percentage(part, total)
        total.zero? ? 0 : ((part.to_f / total) * 100).round(2)
      end

      def calculate_and_format_percentage(part, total)
        format_percentage(calculate_percentage(part, total))
      end

      def answer_options_table_name
        @answer_options_table_name ||= Decidim::Meetings::AnswerOption.table_name
      end

      def answers_table_name
        @answers_table_name ||= Decidim::Meetings::Answer.table_name
      end
    end
  end
end
