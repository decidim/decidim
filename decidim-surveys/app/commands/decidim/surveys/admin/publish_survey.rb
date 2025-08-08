# frozen_string_literal: true

module Decidim
  module Surveys
    module Admin
      # A command with all the business logic that publishes an
      # existing survey.
      class PublishSurvey < Decidim::Command
        # Public: Initializes the command.
        #
        # survey - Decidim::Surveys::Survey
        # current_user - the user performing the action
        def initialize(survey, current_user)
          @survey = survey
          @current_user = current_user
          @questionnaire = survey.questionnaire
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if survey.published?

          transaction do
            publish_survey
            delete_responses if @survey.clean_after_publish?
          end

          broadcast(:ok, survey)
        end

        private

        attr_reader :survey, :current_user

        def publish_survey
          @survey = Decidim.traceability.perform_action!(
            :publish,
            survey,
            current_user,
            visibility: "all"
          ) do
            survey.publish!
            survey
          end
        end

        def delete_responses
          @questionnaire.responses.destroy_all
        end
      end
    end
  end
end
