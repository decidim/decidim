# frozen_string_literal: true

module Decidim
  module Surveys
    module Admin
      # A command with all the business logic that unpublishes an
      # existing survey.
      class UnpublishSurvey < Decidim::Command
        # Public: Initializes the command.
        #
        # survey - Decidim::Surveys::Survey
        # current_user - the user performing the action
        def initialize(survey, current_user)
          @survey = survey
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless survey.published?

          @survey = Decidim.traceability.perform_action!(
            :unpublish,
            survey,
            current_user
          ) do
            survey.unpublish!
            survey
          end
          broadcast(:ok, survey)
        end

        private

        attr_reader :survey, :current_user
      end
    end
  end
end
