# frozen_string_literal: true

module Decidim
  module Surveys
    # This command is executed when the admin publishes the Responses from the admin
    # panel.
    class PublishResponses < Decidim::Command
      include Decidim::TranslatableAttributes

      # Initializes a PublishResponses Command.
      #
      def initialize(question_id, current_user)
        @question_id = question_id
        @current_user = current_user
      end

      # Publishes the questions' responses
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        transaction do
          publish_survey_response
          create_action_log
        end

        broadcast(:ok)
      rescue StandardError
        broadcast(:invalid)
      end

      private

      attr_reader :question_id, :current_user

      def publish_survey_response
        question.update(survey_responses_published_at: Time.current)
      end

      def question
        Decidim::Forms::Question.find(question_id)
      end

      def create_action_log
        Decidim::ActionLogger.log(
          "publish_responses",
          current_user,
          question,
          nil,
          resource: { title: translated_attribute(question.body) },
          participatory_space: { title: question.questionnaire.questionnaire_for.title }
        )
      end
    end
  end
end
