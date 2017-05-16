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
            update_survey_questions if questions_are_editable?
            update_survey
          end

          broadcast(:ok)
        end

        private

        def update_survey_questions
          @form.questions.each do |form_question|
            if form_question.id.present?
              question = @survey.questions.where(id: form_question.id).first
              if form_question.deleted?
                question.destroy!
              else
                question.update_attributes!(body: form_question.body)
              end
            else
              @survey.questions.create!(body: form_question.body)
            end
          end
        end

        def update_survey
          attributes = {
            title: @form.title,
            description: @form.description,
            toc: @form.toc
          }

          if @form.published_at.present?
            attributes[:published_at] = @form.published_at
          end

          @survey.update_attributes!(attributes)
        end

        def questions_are_editable?
          !@survey.published?
        end
      end
    end
  end
end
