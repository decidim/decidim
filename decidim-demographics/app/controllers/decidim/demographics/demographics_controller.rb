# frozen_string_literal: true

module Decidim
  module Demographics
    class DemographicsController < Decidim::Demographics::ApplicationController
      include Decidim::Forms::Concerns::HasQuestionnaire
      include Decidim::UserProfile

      helper_method :allow_editing_responses?, :demographic

      def show
        @form = form(Decidim::Forms::QuestionnaireForm).from_model(questionnaire)
        @form.add_responses!(questionnaire:, session_token:, ip_hash:)
        @form.allow_editing_responses = true

        render template:
      end

      def destroy
        DeleteDemographicData.call(questionnaire, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("destroy.success", scope: "decidim.demographics")
            redirect_to demographics_engine.demographics_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("destroy.error", scope: "decidim.demographics")
            redirect_to demographics_engine.demographics_path
          end
        end
      end

      def template
        "decidim/demographics/demographics/show"
      end

      private

      def after_response_path = demographics_path

      def form_path = demographics_path

      def update_url = respond_demographics_path

      def allow_responses?
        demographic.collect_data?
      end

      def allow_editing_responses?
        demographic.collect_data?
      end

      def questionnaire_for = demographic

      def demographic
        @demographic ||= Decidim::Demographics::Demographic.where(organization: current_organization).first_or_create!
      end

      def enforce_permission_to_respond_questionnaire
        enforce_permission_to :respond, :demographics
      end
    end
  end
end
