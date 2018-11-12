# frozen_string_literal: true

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
        Decidim::SettingsChange.subscribe "surveys" do |changes|
          Decidim::Surveys::SettingsChangeJob.perform_later(
            changes[:component_id],
            changes[:previous_settings],
            changes[:current_settings]
          )
        end
      end

      initializer "decidim_surveys.register_metrics" do
        Decidim.metrics_operation.register(:participants, :surveys) do |metric_operation|
          metric_operation.manager_class = "Decidim::Surveys::Metrics::SurveysMetricMeasure"
        end
      end
    end
  end
end
