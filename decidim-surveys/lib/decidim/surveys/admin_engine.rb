# frozen_string_literal: true

module Decidim
  module Surveys
    # This is the engine that runs on the public interface of `Surveys`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Surveys::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        get "/answer_options", to: "surveys#answer_options", as: :answer_options_survey
        resources :surveys, except: [:new] do
          member do
            get :edit_questions
            patch :update_questions
            put :publish
            put :unpublish
          end
          resources :answers, only: [:index, :show] do
            member do
              get :export_response
            end
          end
        end
        root to: "surveys#index"
      end

      initializer "decidim_surveys_admin.notifications.components" do
        config.to_prepare do
          Decidim::EventsManager.subscribe(/^decidim\.events\.components/) do |event_name, data|
            CleanSurveyAnswersJob.perform_later(event_name, data)
          end
        end
      end

      def load_seed
        nil
      end
    end
  end
end
