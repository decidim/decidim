# frozen_string_literal: true

module Decidim
  module Surveys
    # This command is executed when the admin publishes the Answers from the admin
    # panel.
    class PublishAnswers < Decidim::Command
      # Initializes a PublishAnswers Command.
      #
      # form - The form from which to get the data.
      def initialize(form, survey)
        @form = form
        @survey = survey
      end

      # Publishes the answers if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if @form.invalid?

        Decidim.traceability.perform_action!(:publish_answers, @form.questionnaire, @form.current_user) do
          publish_survey_answers
          unpublish_survey_answers
        end

        broadcast(:ok)
      end

      private

      attr_reader :form, :survey

      def publish_survey_answers
        questions.update_all(survey_answers_published_at: Time.current) # rubocop:disable Rails/SkipsModelValidations
      end

      def unpublish_survey_answers
        # unpublish the questions that are not selected, just in case the form is updated and some questions are removed
        survey.questionnaire.questions.where.not(id: form.question_ids.compact).update_all(survey_answers_published_at: nil) # rubocop:disable Rails/SkipsModelValidations
      end

      def questions
        Decidim::Forms::Question.where(id: form.question_ids)
      end
    end
  end
end
