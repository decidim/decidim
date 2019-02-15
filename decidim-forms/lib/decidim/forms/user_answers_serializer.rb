# frozen_string_literal: true

module Decidim
  module Forms
    # This class serializes the answers given by a User for questionnaire so can be
    # exported to CSV, JSON or other formats.
    class UserAnswersSerializer < Decidim::Exporters::Serializer
      include Decidim::TranslationsHelper

      # Public: Initializes the serializer with a collection of Answers.
      def initialize(answers)
        @answers = answers
      end

      # Public: Exports a hash with the serialized data for the user answers.
      def serialize
        @answers.each_with_index.inject({}) do |serialized, (answer, idx)|
          serialized.update("#{idx + 1}. #{translated_attribute(answer.question.body)}" => normalize_body(answer))
        end
      end

      private

      def normalize_body(answer)
        answer.body || normalize_choices(answer.choices)
      end

      def normalize_choices(choices)
        choices.map do |choice|
          choice.try(:custom_body) || choice.try(:body)
        end
      end
    end
  end
end
