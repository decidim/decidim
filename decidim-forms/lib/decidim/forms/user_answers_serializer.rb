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
        answers_hash = hash_for(@answers.first)
        answers_hash.merge!(questions_hash)

        @answers.each do |answer|
          answers_hash[translated_question_key(answer.question.position, answer.question.body)] = normalize_body(answer)
        end

        answers_hash
      end

      private

      attr_reader :answers
      alias resource answers

      def hash_for(answer)
        {
          answer_translated_attribute_name(:id) => answer&.session_token,
          answer_translated_attribute_name(:created_at) => answer&.created_at&.to_s(:db),
          answer_translated_attribute_name(:ip_hash) => answer&.ip_hash,
          answer_translated_attribute_name(:user_status) => answer_translated_attribute_name(answer&.decidim_user_id.present? ? "registered" : "unregistered")
        }
      end

      def questions_hash
        return {} if questionnaire&.questions.blank?

        questionnaire.questions.each.inject({}) do |serialized, question|
          serialized.update(
            translated_question_key(question.position, question.body) => ""
          )
        end
      end

      def questionnaire
        @answers.first&.questionnaire
      end

      def translated_question_key(idx, body)
        "#{idx + 1}. #{translated_attribute(body)}"
      end

      def normalize_body(answer)
        answer.body ||
          normalize_attachments(answer) ||
          normalize_choices(answer, answer.choices)
      end

      def normalize_attachments(answer)
        return if answer.attachments.blank?

        answer.attachments.map(&:url)
      end

      def normalize_choices(answer, choices)
        if answer.question.matrix?
          normalize_matrix_choices(answer, choices)
        else
          choices.map do |choice|
            format_free_text_for choice
          end
        end
      end

      def normalize_matrix_choices(answer, choices)
        answer.question.matrix_rows.to_h do |matrix_row|
          row_body = translated_attribute(matrix_row.body)

          row_choices = answer.question.answer_options.map do |answer_option|
            choice = choices.find_by(matrix_row:, answer_option:)
            choice.try(:custom_body) || choice.try(:body)
          end

          [row_body, row_choices]
        end
      end

      def answer_translated_attribute_name(attribute)
        I18n.t(attribute.to_sym, scope: "decidim.forms.user_answers_serializer")
      end

      def format_free_text_for(choice)
        return choice.try(:body) if choice.try(:custom_body).blank?

        "#{choice.try(:body)} (#{choice.try(:custom_body)})"
      end
    end
  end
end
