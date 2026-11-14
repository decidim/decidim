# frozen_string_literal: true

module Decidim
  module Surveys
    module Admin
      # This command is executed when the user deletes all the submissions of a survey
      # from the admin panel.
      class DeleteSurveySubmissions < Decidim::Command
        # Initializes a DeleteSurveySubmissions Command.
        #
        # survey - The current instance of the survey whose submissions will be deleted.
        # current_user - the user performing the action
        def initialize(survey, current_user)
          @survey = survey
          @current_user = current_user
        end

        # Deletes all the survey submissions.
        #
        # Broadcasts :ok if successful.
        def call
          return broadcast(:invalid) unless questionnaire

          Decidim.traceability.perform_action!(
            "delete_all_responses",
            questionnaire,
            current_user
          ) do
            questionnaire.submissions.find_each(&:destroy)
          end

          broadcast(:ok)
        end

        private

        attr_reader :survey, :current_user

        def questionnaire
          @questionnaire ||= survey.questionnaire
        end
      end
    end
  end
end
