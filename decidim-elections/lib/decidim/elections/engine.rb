# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module Elections
    # This is the engine that runs on the public interface of elections.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Elections

      routes do
        resources :elections, only: [:index, :show]

        root to: "elections#index"
      end

      initializer "decidim_elections.assets" do |app|
        app.config.assets.precompile += %w(decidim_elections_manifest.js decidim_elections_manifest.css)
      end
    end
  end
end
