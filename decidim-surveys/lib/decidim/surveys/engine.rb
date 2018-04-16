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

      initializer "decidim_surveys.assets" do |app|
        app.config.assets.precompile += %w(decidim_surveys_manifest.js)
      end

      initializer "decidim_surveys.inject_abilities_to_user" do |_app|
        Decidim.configure do |config|
          config.abilities += ["Decidim::Surveys::Abilities::CurrentUserAbility"]
        end
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
    end
  end
end
