# frozen_string_literal: true

require "rails"
require "active_support/all"

require "decidim/core"

module Decidim
  module Sortitions
    # Decidim's Sortitions Rails Engine.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Sortitions

      routes do
        resources :sortitions, only: [:index, :show] do
          resource :sortition_widget, only: :show, path: "embed"
        end
        root to: "sortitions#index"
      end

      initializer "decidim_sorititions.assets" do |app|
        app.config.assets.precompile += %w(decidim_sortitions_manifest.js decidim_sortitions_manifest.css)
      end

      initializer "decidim_sortitions.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Sortitions::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Sortitions::Engine.root}/app/views") # for proposal partials
      end
    end
  end
end
