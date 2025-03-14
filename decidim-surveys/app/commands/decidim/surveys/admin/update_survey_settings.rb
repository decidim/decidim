# frozen_string_literal: true

module Decidim
  module Surveys
    module Admin
      # This command is executed when the user changes a Survey Settings (also known as their attributes) from the admin
      # panel.
      class UpdateSurveySettings < Decidim::Forms::Admin::UpdateQuestionnaire
        # Initializes a UpdateSurveySettings Command.
        #
        # form - The form from which to get the data.
        # survey - The current instance of the survey to be updated.
        # user - The user doing the update
        def initialize(form, survey, user)
          @form = form
          @survey = survey
          @user = user
        end

        attr_reader :form, :survey, :user

        # Updates the survey questionnaire if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          Decidim.traceability.perform_action!("update", survey, user) do
            transaction do
              update_survey_settings
            end
          rescue ActiveRecord::RecordInvalid
            broadcast(:invalid)
          end

          broadcast(:ok)
        end

        private

        def update_survey_settings
          survey.update!(
            allow_responses: form.allow_responses,
            allow_editing_responses: form.allow_editing_responses,
            allow_unregistered: form.allow_unregistered,
            starts_at: form.starts_at,
            ends_at: form.ends_at,
            clean_after_publish: form.clean_after_publish,
            announcement: form.announcement
          )
        end
      end
    end
  end
end
