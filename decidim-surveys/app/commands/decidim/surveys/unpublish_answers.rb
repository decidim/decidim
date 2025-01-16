# frozen_string_literal: true

module Decidim
  module Surveys
    # This command is executed when the admin unpublishes the Answers from the admin
    # panel.
    class UnpublishAnswers < Decidim::Command
      # Initializes a UnpublishAnswers Command.
      #
      def initialize(question_id, current_user)
        @question_id = question_id
        @current_user = current_user
      end

      # Unpublishes the questions' answers
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        Decidim.traceability.perform_action!(:unpublish_answers, question, current_user) do
          unpublish_survey_answer
        end

        broadcast(:ok)
      rescue StandardError
        broadcast(:invalid)
      end

      private

      attr_reader :question_id, :current_user

      def unpublish_survey_answer
        question.update(survey_answers_published_at: nil)
      end

      def question
        Decidim::Forms::Question.find(question_id)
      end
    end
  end
end
