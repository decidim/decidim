# frozen_string_literal: true

module Decidim
  module Surveys
    # This command is executed when the user answers a Survey.
    class AnswerSurvey < Rectify::Command
      # Initializes a AnswerSurvey Command.
      #
      # form - The form from which to get the data.
      # survey - The current instance of the survey to be answered.
      def initialize(form, current_user, survey)
        @form = form
        @current_user = current_user
        @survey = survey
      end

      # Answers a survey if it is valid
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if @form.invalid?

        answer_survey
        broadcast(:ok)
      end

      private

      def answer_survey
        SurveyAnswer.transaction do
          @form.survey_answers.each do |form_answer|
            answer = SurveyAnswer.new(
              user: @current_user,
              survey: @survey,
              question: form_answer.question,
              body: form_answer.body
            )

            form_answer.selected_choices.each do |choice|
              answer.choices.build(
                body: choice.body,
                custom_body: choice.custom_body,
                decidim_survey_answer_option_id: choice.answer_option_id,
                position: choice.position
              )
            end

            answer.save!
          end
        end
      end
    end
  end
end
