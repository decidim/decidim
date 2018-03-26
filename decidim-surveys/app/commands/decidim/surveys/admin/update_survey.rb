# frozen_string_literal: true

module Decidim
  module Surveys
    module Admin
      # This command is executed when the user changes a Survey from the admin
      # panel.
      class UpdateSurvey < Rectify::Command
        # Initializes a UpdateSurvey Command.
        #
        # form - The form from which to get the data.
        # survey - The current instance of the survey to be updated.
        def initialize(form, survey)
          @form = form
          @survey = survey
        end

        # Updates the survey if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if @form.invalid?

          Survey.transaction do
            update_survey_questions if @survey.questions_editable?
            update_survey
          end

          broadcast(:ok)
        end

        private

        def update_survey_questions
          @form.questions.each do |form_question|
            question_attributes = {
              body: form_question.body,
              description: form_question.description,
              position: form_question.position,
              mandatory: form_question.mandatory,
              question_type: form_question.question_type,
              answer_options: form_question.answer_options_to_persist.map { |answer| { "body" => answer.body } }
            }

            if form_question.id.present?
              question = @survey.questions.where(id: form_question.id).first
              if form_question.deleted?
                question.destroy!
              else
                question.update!(question_attributes)
              end
            else
              @survey.questions.create!(question_attributes)
            end
          end
        end

        def update_survey
          @survey.update!(title: @form.title,
                          description: @form.description,
                          tos: @form.tos)
        end
      end
    end
  end
end
