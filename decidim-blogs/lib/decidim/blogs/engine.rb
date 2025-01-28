# frozen_string_literal: true

require "rails"
require "active_support/all"

require "decidim/core"

module Decidim
  module Blogs
    # This is the engine that runs on the public interface of `decidim-blogs`.
    # It mostly handles rendering the created blogs associated to a participatory
    # process.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Blogs

      routes do
        resources :posts
        scope "/posts" do
          root to: "posts#index"
        end
        get "/", to: redirect("posts", status: 301)
      end

      initializer "decidim_blogs.register_icons" do
        Decidim.icons.register(name: "Decidim::Blogs::Post", icon: "pen-nib-line", description: "Blogs post", category: "activity", engine: :core)
      end

      initializer "decidim_blogs.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Blogs::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Blogs::Engine.root}/app/views") # for partials
      end

      initializer "decidim_blogs.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_blogs.authorization_transfer" do
        config.to_prepare do
          Decidim::AuthorizationTransfer.register(:blogs) do |transfer|
            transfer.move_records(Decidim::Blogs::Post, :decidim_author_id)
          end
        end
      end
    end
  end
end
