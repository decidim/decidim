# frozen_string_literal: true

module Decidim
  module Surveys
    module Admin
      # This controller allows the user to update a Page.
      class PublishAnswersController < Admin::ApplicationController
        include Decidim::Forms::Admin::Concerns::HasQuestionnaireAnswersUrlHelper

        def new
          # FIXME: update to correct permisison
          enforce_permission_to :show, :questionnaire_answers

          @survey ||= survey
          @form = form(Decidim::Forms::Admin::PublishAnswersForm).from_model(@survey)

          render :new
        end

        def create
          # FIXME: update to correct permisison
          enforce_permission_to :show, :questionnaire_answers

          @survey ||= survey
          @form = form(Decidim::Forms::Admin::PublishAnswersForm).from_params(params).with_context(current_user:)
          Decidim::Surveys::PublishAnswers.call(@form, survey) do
            on(:ok) do
              flash[:notice] = I18n.t("success", scope: "decidim.surveys.admin.publish_answers.callout")
              redirect_to questionnaire_url
            end

            on(:invalid) do
              flash[:notice] = I18n.t("invalid", scope: "decidim.surveys.admin.publish_answers.callout")
              render template: :new
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
