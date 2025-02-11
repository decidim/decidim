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

      helper PublishAnswersHelper
      helper_method :authorizations, :surveys, :show_published_questions_answers?

      before_action :check_permissions, except: [:index]
      before_action :check_editable, only: [:edit]

      def index; end

      def edit
        @form = form(Decidim::Forms::QuestionnaireForm).from_model(questionnaire)
        @form.add_answers!(questionnaire:, session_token:, ip_hash:)
        @form.allow_editing_answers = questionnaire.questionnaire_for&.allow_editing_answers?

        render template: "decidim/forms/questionnaires/edit"
      end

      def check_permissions
        render :no_permission unless action_authorized_to(:answer, resource: survey).ok?
      end

      def questionnaire_for
        survey
      end

      protected

      def check_editable
        return if allow_editing_answers?

        flash.now[:error] = t("decidim.forms.step_navigation.show.disallowed")
        render :not_allowed
      end

      def allow_editing_answers?
        visitor_can_edit_answers? && survey.open?
      end

      def show_published_questions_answers?
        survey.closed? && survey.questionnaire.questions.pluck(:survey_answers_published_at).any?
      end

      def allow_answers?
        !current_component.published? || survey.open?
      end

      def allow_unregistered?
        survey.allow_unregistered
      end

      def form_path
        main_component_path(current_component)
      end

      private

      def i18n_flashes_scope
        "decidim.surveys.surveys"
      end

      def surveys
        paginate(search.result).published
      end

      def survey
        @survey ||= search_collection.find_by(id: params[:id])
      end

      def search_collection
        @search_collection ||= Decidim::Surveys::Survey.where(component: current_component)
      end

      def default_filter_params
        {
          with_any_state: %w(open)
        }
      end
    end
  end
end
