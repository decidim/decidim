# frozen_string_literal: true

require "decidim/core"

module Decidim
  module Surveys
    # This is the engine that runs on the public interface of `decidim-surveys`.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Surveys

      routes do
        resources :surveys, only: [:index, :show, :edit] do
          member do
            post :respond
          end
        end
        root to: "surveys#index"
      end

      initializer "decidim_surveys.settings_changes" do
        config.to_prepare do
          Decidim::SettingsChange.subscribe "surveys" do |changes|
            Decidim::Surveys::SettingsChangeJob.perform_later(
              changes[:component_id],
              changes[:previous_settings],
              changes[:current_settings]
            )
          end
        end
      end

      initializer "decidim_surveys.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_surveys.responses_email" do
        config.to_prepare do
          ActiveSupport::Notifications.subscribe("decidim.forms.response_questionnaire:after") do |_event_name, data|
            extra_data = data[:extra]
            if data[:resource].questionnaire_for.instance_of?(::Decidim::Surveys::Survey)
              component = data[:resource].questionnaire_for.component

              responses = Decidim::Forms::QuestionnaireUserResponses.for(data[:resource])
              user_responses = responses.select { |a| a.first.session_token == extra_data[:session_token] }

              if component.manifest_name == "surveys" && user_responses.present?
                Decidim::Surveys::SurveyConfirmationMailer.confirmation(extra_data[:event_author], extra_data[:questionnaire], user_responses).deliver_later
              end
            end
          end
        end
      end
    end
  end
end
