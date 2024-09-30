# frozen_string_literal: true

module Decidim
  module Surveys
    # Exposes the survey resource so users can view and answer them.
    class SurveysController < Decidim::Surveys::ApplicationController
      include Decidim::Forms::Concerns::HasQuestionnaire
      include Decidim::ComponentPathHelper
      include Decidim::Surveys::SurveyHelper
      include FilterResource
      include Paginable

      helper_method :authorizations, :surveys

      before_action :check_permissions, except: [:index]

      def index; end

      def show
        raise ActionController::RoutingError, "Not Found" unless survey

        return if survey.current_user_can_visit_survey?(current_user)

        flash[:alert] = I18n.t("survey.not_allowed", scope: "decidim.surveys")
        redirect_to(ResourceLocatorPresenter.new(survey).index)
      end

      def check_permissions
        render :no_permission unless action_authorized_to(:answer, resource: survey).ok?
      end

      def questionnaire_for
        survey
      end

      protected

      def allow_answers?
        !current_component.published? || (survey.allow_answers? && survey.open?)
      end

      def form_path
        main_component_path(current_component)
      end

      private

      def i18n_flashes_scope
        "decidim.surveys.surveys"
      end

      def surveys
        paginate(collection)
      end

      def survey
        @survey ||= collection.find_by(id: params[:id])
      end

      def collection
        @collection ||= Decidim::Surveys::Survey.where(component: current_component)
      end
    end
  end
end
