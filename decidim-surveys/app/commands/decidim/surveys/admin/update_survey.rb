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
            update_survey_question(form_question)
          end
        end

        def update_survey_question(form_question)
          question_attributes = {
            body: form_question.body,
            description: form_question.description,
            position: form_question.position,
            mandatory: form_question.mandatory,
            question_type: form_question.question_type,
            answer_options: form_question.answer_options_to_persist.map { |option| { "body" => option.body } },
            max_choices: form_question.max_choices
          }

          questions = @survey.questions

          question = questions.find_by(id: form_question.id) || questions.build(question_attributes)

          if question.persisted?
            if form_question.deleted?
              question.destroy!
            else
              question.assign_attributes(question_attributes)
            end
          end

          question.save!
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
