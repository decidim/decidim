# frozen_string_literal: true

module Decidim
  module Surveys
    module Admin
      # This controller allows the user to see which questions' responses can be published, and publish or unpublish them
      class PublishResponsesController < Admin::ApplicationController
        include Decidim::Forms::Admin::Concerns::HasQuestionnaireResponsesUrlHelper

        helper PublishResponsesHelper

        def index
          enforce_permission_to(:index, :questionnaire_publish_responses, survey:)

          @survey ||= survey
        end

        def update
          enforce_permission_to(:update, :questionnaire_publish_responses, survey:)

          Decidim::Surveys::PublishResponses.call(params[:id], current_user) do
            on(:ok) do
              render json: {}
            end

            on(:invalid) do
              render json: {}, status: :unprocessable_entity
            end
          end
        end

        def destroy
          enforce_permission_to(:destroy, :questionnaire_publish_responses, survey:)

          Decidim::Surveys::UnpublishResponses.call(params[:id], current_user) do
            on(:ok) do
              render json: {}
            end

            on(:invalid) do
              render json: {}, status: :unprocessable_entity
            end
          end
        end

        def questionnaire
          @questionnaire ||= Decidim::Forms::Questionnaire.find_by(questionnaire_for:)
        end

        def questionnaire_for
          survey
        end

        def questionnaire_url
          Decidim::EngineRouter.admin_proxy(questionnaire_for.component).edit_questions_survey_path(questionnaire_for)
        end

        private

        def survey
          @survey ||= Survey.where(component: current_component).find(params[:survey_id])
        end
      end
    end
  end
end
