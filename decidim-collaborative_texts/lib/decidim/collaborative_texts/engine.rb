# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::CollaborativeTexts

      routes do
        resources :documents do
          resources :suggestions
        end
        scope "/documents" do
          root to: "documents#index"
        end
        get "/", to: redirect("documents", status: 301)
      end

      initializer "decidim_collaborative_texts.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_collaborative_texts.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::CollaborativeTexts::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::CollaborativeTexts::Engine.root}/app/views") # for partials
      end
    end
  end
end
