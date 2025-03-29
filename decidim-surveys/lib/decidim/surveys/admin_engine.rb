# frozen_string_literal: true

module Decidim
  module Surveys
    # This is the engine that runs on the public interface of `Surveys`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Surveys::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        get "/response_options", to: "questions/surveys#response_options", as: :response_options_survey

        resources :surveys do
          member do
            put :publish
            put :unpublish

            namespace :questions do
              get :edit_questions
              patch :update_questions
              get :edit
              patch :update
            end

            namespace :settings do
              get :edit
              patch :update
            end
          end
          resources :responses, only: [:index, :show] do
            member do
              get :export_response
            end
          end
          resources :publish_responses, only: [:index, :update, :destroy]
        end
        root to: "surveys#index"
      end

      initializer "decidim_surveys_admin.menu" do
        Decidim.menu :admin_surveys_menu do |menu|
          responses_count = @survey.nil? ? 0 : Decidim::Forms::QuestionnaireParticipants.new(@survey.questionnaire).count_participants
          responses_caption = I18n.t("responses", scope: "decidim.admin.menu.surveys_menu")
          responses_caption += content_tag(:span, responses_count, class: "component-counter")

          menu.add_item :main_survey,
                        I18n.t("main", scope: "decidim.admin.menu.surveys_menu"),
                        @survey.nil? ? new_survey_path : Decidim::EngineRouter.admin_proxy(@survey.component).edit_survey_path(@survey),
                        icon_name: "bill-line"

          menu.add_item :survey_questions_edit,
                        I18n.t("questions", scope: "decidim.admin.menu.surveys_menu"),
                        @survey.nil? ? "#" : Decidim::EngineRouter.admin_proxy(@survey.component).edit_questions_questions_survey_path(@survey),
                        icon_name: "question-answer-line"

          menu.add_item :survey_responses_view,
                        responses_caption.html_safe,
                        @survey.nil? ? "#" : Decidim::EngineRouter.admin_proxy(@survey.component).survey_responses_path(@survey),
                        icon_name: "draft-line"

          menu.add_item :survey_settings_edit,
                        I18n.t("settings", scope: "decidim.admin.menu.surveys_menu"),
                        @survey.nil? ? "#" : Decidim::EngineRouter.admin_proxy(@survey.component).edit_settings_survey_path(@survey),
                        icon_name: "settings-4-line"
        end
      end

      initializer "decidim_surveys_admin.notifications.components" do
        config.to_prepare do
          Decidim::EventsManager.subscribe(/^decidim\.events\.components/) do |event_name, data|
            CleanSurveyResponsesJob.perform_later(event_name, data)
          end
        end
      end

      def load_seed
        nil
      end
    end
  end
end
