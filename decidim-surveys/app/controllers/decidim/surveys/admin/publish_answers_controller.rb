# frozen_string_literal: true

module Decidim
  module Surveys
    module Admin
      # This controller allows the user to update a Page.
      class PublishAnswersController < Admin::ApplicationController
        include Decidim::Forms::Admin::Concerns::HasQuestionnaireAnswersUrlHelper

        def index
          # FIXME: update to correct permission
          enforce_permission_to :show, :questionnaire_answers

          @survey ||= survey
        end

        def update
          # FIXME: update to correct permission
          enforce_permission_to :show, :questionnaire_answers

          Decidim::Surveys::PublishAnswers.call(params[:id], current_user) do
            on(:ok) do
              render json: {}
            end

            on(:invalid) do
              render json: {}, status: :unprocessable_entity
            end
          end
        end

        def destroy
          # FIXME: update to correct permission
          enforce_permission_to :show, :questionnaire_answers

          Decidim::Surveys::UnpublishAnswers.call(params[:id], current_user) do
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

        private

        def survey
          @survey ||= Survey.find_by(component: current_component)
        end
      end
    end
  end
end
