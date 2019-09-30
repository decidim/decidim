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
          serialized.update(
            answer_translated_attribute_name(:id) => answer.id,
            answer_translated_attribute_name(:created_at) => answer.created_at.to_s(:db),
            answer_translated_attribute_name(:ip_hash) => answer.ip_hash,
            answer_translated_attribute_name(:user_status) => answer_translated_attribute_name(answer.decidim_user_id.present? ? "registered" : "unregistered"),
            "#{idx + 1}. #{translated_attribute(answer.question.body)}" => normalize_body(answer)
          )
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

      def answer_translated_attribute_name(attribute)
        I18n.t(attribute.to_sym, scope: "decidim.forms.user_answers_serializer")
      end
    end
  end
end
