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

          update_survey
          broadcast(:ok)
        end

        private

        def update_survey
          @survey.update_attributes!(
            title: @form.title,
            description: @form.description,
            toc: @form.toc
          )

          @form.questions.each do |form_question|
            if form_question.id.present?
              @survey.questions.where(id: form_question.id).first.update_attributes!(body: form_question.body)
            else
              @survey.questions.create(body: form_question.body)
            end
          end
        end
      end
    end
  end
end
