# frozen_string_literal: true

module Decidim
  module Meetings
    # This cell renders the percentage of responses which chose
    # the given response option in a meeting poll question
    class QuestionResponsesCell < Decidim::ViewModel
      def show
        render
      end

      private

      # Returns an array of arrays, where the internal array contains
      #   - the body of the response option
      #   - the percentage of responses for that option
      #
      def response_options_with_percentages
        # This query joins response options with response choices and responses
        # and returns for each response option the count of times it has been responded
        # grouping by response options and responses.
        #
        # This calculation is a bit complex because of multiple option responses
        question_responses_choices = Decidim::Meetings::ResponseOption.where(decidim_question_id: model.id)
                                                                      .joins([choices: :response])
                                                                      .group(Arel.sql("#{responses_table_name}.id, #{response_options_table_name}.id"))
                                                                      .select(<<~SELECT
                                                                        #{response_options_table_name}.id AS id,
                                                                        #{response_options_table_name}.body,
                                                                        #{responses_table_name}.id AS response_id,
                                                                        COUNT(decidim_response_option_id) AS count
                                                                      SELECT
                                                                             )

        # Extract the number of uniq responses by the response_id attribute
        total_responses = question_responses_choices.map(&:response_id).compact.uniq.size

        # A second grouping is necessary to count the number of responses for each response_option id
        # and calculate the percentages
        options_with_percentages = []
        question_responses_choices.group_by(&:id).each do |_id, values|
          responses_count = values.sum(&:count)
          options_with_percentages << [values.first.body, calculate_and_format_percentage(responses_count, total_responses)]
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

      def response_options_table_name
        @response_options_table_name ||= Decidim::Meetings::ResponseOption.table_name
      end

      def responses_table_name
        @responses_table_name ||= Decidim::Meetings::Response.table_name
      end
    end
  end
end
