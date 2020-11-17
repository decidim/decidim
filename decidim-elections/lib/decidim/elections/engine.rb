# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module Elections
    # This is the engine that runs on the public interface of elections.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Elections

      routes do
        resources :elections, only: [:index, :show] do
          resource :feedback, only: [:show] do
            post :answer
          end

          resource :vote
        end

        root to: "elections#index"
      end

      initializer "decidim_elections.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Elections::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Elections::Engine.root}/app/views") # for partials
      end

      initializer "decidim_elections.assets" do |app|
        app.config.assets.precompile += %w(decidim_elections_manifest.js decidim_elections_manifest.css)
      end
    end
  end
end
