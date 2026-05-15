# frozen_string_literal: true

module Decidim
  module Forms
    # This class serializes the responses given by a User for questionnaire so can be
    # exported to CSV, JSON or other formats.
    class UserResponsesSerializer < Decidim::Exporters::Serializer
      include Decidim::TranslationsHelper

      # Public: Initializes the serializer with a collection of Responses.
      def initialize(responses)
        @responses = responses
      end

      # i18n-tasks-use t('decidim.forms.user_responses_serializer.body')
      # i18n-tasks-use t('decidim.forms.user_responses_serializer.id')
      # i18n-tasks-use t('decidim.forms.user_responses_serializer.question')
      # i18n-tasks-use t('decidim.forms.user_responses_serializer.registered')
      # i18n-tasks-use t('decidim.forms.user_responses_serializer.unregistered')
      # Public: Exports a hash with the serialized data for the user responses.
      def serialize
        responses_hash = hash_for(@responses.first)
        responses_hash.merge!(questions_hash)

        @responses.each do |response|
          responses_hash[translated_question_key(response.question.position, response.question.body)] = normalize_body(response)
        end

        responses_hash
      end

      private

      attr_reader :responses
      alias resource responses

      def hash_for(response)
        {
          response_translated_attribute_name(:id) => response&.session_token,
          response_translated_attribute_name(:created_at) => response&.created_at,
          response_translated_attribute_name(:ip_hash) => response&.ip_hash,
          response_translated_attribute_name(:user_status) => response_translated_attribute_name(response&.decidim_user_id.present? ? "registered" : "unregistered")
        }
      end

      def questions_hash
        questionnaire_id = @responses.first&.decidim_questionnaire_id
        return {} unless questionnaire_id

        questions = Decidim::Forms::Question.where(decidim_questionnaire_id: questionnaire_id).order(:position)
        return {} if questions.none?

        questions.each.inject({}) do |serialized, question|
          serialized.update(
            translated_question_key(question.position, question.body) => ""
          )
        end
      end

      def translated_question_key(idx, body)
        "#{idx + 1}. #{translated_attribute(body)}"
      end

      def normalize_body(response)
        response.body ||
          normalize_attachments(response) ||
          normalize_choices(response, response.choices)
      end

      def normalize_attachments(response)
        return if response.attachments.blank?

        response.attachments.map(&:url)
      end

      def normalize_choices(response, choices)
        if response.question.matrix?
          normalize_matrix_choices(response, choices)
        else
          choices.map do |choice|
            format_free_text_for choice
          end
        end
      end

      def normalize_matrix_choices(response, choices)
        response.question.matrix_rows.to_h do |matrix_row|
          row_body = translated_attribute(matrix_row.body)

          row_choices = response.question.response_options.map do |response_option|
            choice = choices.find_by(matrix_row:, response_option:)
            choice.try(:custom_body) || choice.try(:body)
          end

          [row_body, row_choices]
        end
      end

      def response_translated_attribute_name(attribute)
        I18n.t(attribute.to_sym, scope: "decidim.forms.user_responses_serializer")
      end

      def format_free_text_for(choice)
        return choice.try(:body) if choice.try(:custom_body).blank?

        "#{choice.try(:body)} (#{choice.try(:custom_body)})"
      end
    end
  end
end
