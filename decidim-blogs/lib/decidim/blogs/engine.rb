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
        resources :posts, only: [:index, :show]
        root to: "posts#index"
      end

      initializer "decidim_blogs.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Blogs::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Blogs::Engine.root}/app/views") # for partials
      end

      initializer "decidim_blogs.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_blogs.authorization_transfer" do
        Decidim::AuthorizationTransfer.subscribe do |authorization, target_user|
          # rubocop:disable Rails/SkipsModelValidations
          Decidim::Blogs::Post.where(author: authorization.user).update_all(
            decidim_author_id: target_user.id
          )
          # rubocop:enable Rails/SkipsModelValidations
        end
      end
    end
  end
end
