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

          resources :votes, only: [:new, :create, :update, :show] do
            get :verify
            match "new", action: :new, via: :post, as: :login, on: :collection
          end

          get :election_log, on: :member
        end
        scope "/elections" do
          root to: "elections#index"
        end
        get "/", to: redirect("elections", status: 301)
      end

      initializer "decidim_elections.register_icons" do
        Decidim.icons.register(name: "Decidim::Elections::Election", icon: "chat-poll-line", description: "Election", category: "activity", engine: :elections)
        Decidim.icons.register(name: "safe-line", icon: "safe-line", category: "system", description: "", engine: :elections)
        Decidim.icons.register(name: "guide-line", icon: "guide-line", category: "system", description: "", engine: :elections)
        Decidim.icons.register(name: "loader-4-line", icon: "loader-4-line", category: "system", description: "", engine: :elections)
        Decidim.icons.register(name: "checkbox-multiple-line", icon: "checkbox-multiple-line", category: "system", description: "", engine: :elections)
        Decidim.icons.register(name: "book-2-line", icon: "book-2-line", category: "system", description: "", engine: :elections)
        Decidim.icons.register(name: "shut-down-line", icon: "shut-down-line", category: "system", description: "", engine: :elections)
        Decidim.icons.register(name: "article-line", icon: "article-line", category: "system", description: "", engine: :elections)
        Decidim.icons.register(name: "bar-chart-box-line", icon: "bar-chart-box-line", category: "system", description: "", engine: :elections)
      end

      initializer "decidim_elections.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Elections::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Elections::Engine.root}/app/views") # for partials
      end

      initializer "decidim_elections.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_elections.authorization_transfer" do
        config.to_prepare do
          Decidim::AuthorizationTransfer.register(:elections) do |transfer|
            transfer.move_records(Decidim::Elections::Vote, :decidim_user_id)
          end
        end
      end
    end
  end
end
