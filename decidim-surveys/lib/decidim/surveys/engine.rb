# frozen_string_literal: true

require "decidim/core"

module Decidim
  module Surveys
    # This is the engine that runs on the public interface of `decidim-surveys`.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Surveys

      routes do
        resources :surveys, only: [:show] do
          member do
            post :answer
          end
        end
        root to: "surveys#show"
      end

      initializer "decidim_changes" do
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

      initializer "decidim_surveys.register_metrics" do
        Decidim.metrics_registry.register(:survey_answers) do |metric_registry|
          metric_registry.manager_class = "Decidim::Surveys::Metrics::AnswersMetricManage"

          metric_registry.settings do |settings|
            settings.attribute :highlighted, type: :boolean, default: false
            settings.attribute :scopes, type: :array, default: %w(participatory_process)
            settings.attribute :weight, type: :integer, default: 5
            settings.attribute :stat_block, type: :string, default: "small"
          end
        end

        Decidim.metrics_operation.register(:participants, :surveys) do |metric_operation|
          metric_operation.manager_class = "Decidim::Surveys::Metrics::SurveyParticipantsMetricMeasure"
        end
      end

      initializer "decidim_surveys.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_surveys.answers_email" do
        config.to_prepare do
          ActiveSupport::Notifications.subscribe("decidim.forms.answer_questionnaire:after") do |_event_name, data|
            extra_data = data[:extra]
            if data[:resource].questionnaire_for.instance_of?(::Decidim::Surveys::Survey)
              component = data[:resource].questionnaire_for.component

              answers = Decidim::Forms::QuestionnaireUserAnswers.for(data[:resource])
              user_answers = answers.select { |a| a.first.session_token == extra_data[:session_token] }

              if component.manifest_name == "surveys" && user_answers.present?
                Decidim::Surveys::SurveyConfirmationMailer.confirmation(extra_data[:event_author], extra_data[:questionnaire], user_answers).deliver_later
              end
            end
          end
        end
      end
    end
  end
end
