# frozen_string_literal: true

module Decidim
  module Surveys
    module Admin
      # This command is executed when the user changes a Survey Questionnaire from the admin
      # panel.
      class UpdateSurvey < Decidim::Forms::Admin::UpdateQuestionnaire
        # Initializes a UpdateSurvey Command.
        #
        # form - The form from which to get the data.
        # survey questionnaire - The current instance of the questionnaire to be updated.
        def initialize(form, survey, user)
          @form = form
          @survey = survey
          @questionnaire = survey.questionnaire
          @user = user
        end

        # Updates the survey questionnaire if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if @form.invalid?

          Decidim.traceability.perform_action!("update", @survey, @user) do
            transaction do
              update_questionnaire_attributes
            end
          rescue ActiveRecord::RecordInvalid
            broadcast(:invalid)
          end

          broadcast(:ok)
        end

        private

        def update_questionnaire_attributes
          @questionnaire.update!(
            title: @form.title,
            description: @form.description,
            tos: @form.tos
          )
        end
      end
    end
  end
end
