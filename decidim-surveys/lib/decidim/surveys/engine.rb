# frozen_string_literal: true

module Decidim
  module Surveys
    # This is the engine that runs on the public interface of `decidim-surveys`.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Surveys

      routes do
        # Add engine routes here
        # resources :surveys
        # root to: "surveys#index"
      end

      initializer "decidim_surveys.assets" do |app|
        app.config.assets.precompile += %w(decidim_surveys_manifest.js decidim_surveys_manifest.css)
      end

      initializer "decidim_surveys.inject_abilities_to_user" do |_app|
        Decidim.configure do |config|
          config.abilities += ["Decidim::Surveys::Abilities::CurrentUser"]
        end
      end
    end
  end
end
