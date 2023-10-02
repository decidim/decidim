# frozen_string_literal: true

require "rails"
require "active_support/all"

require "decidim/core"

module Decidim
  module Design
    # This is the engine that runs on the public interface of `decidim-design`.
    # It mostly handles rendering the created design associated to a participatory
    # process.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Design

      routes do
        namespace :design do
          namespace :components do
            get "forms", to: "forms#index"
            get "cards", to: "cards#index"
            get "spacing", to: "spacing#index"
          end

          namespace :foundations do
            get "accessibility", to: "accessibility#index"
            get "color", to: "color#index"
            get "iconography", to: "iconography#index"
            get "layout", to: "layout#index"
            get "typography", to: "typography#index"
          end

          get "home", to: "home#index"

          root to: "home#index"
        end
      end

      initializer "decidim_design.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Design::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Design::Engine.root}/app/views") # for partials
      end

      initializer "decidim_design.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end
    end
  end
end
