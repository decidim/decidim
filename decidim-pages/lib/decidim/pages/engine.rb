# frozen_string_literal: true

require "decidim/core"

module Decidim
  module Pages
    # This is the engine that runs on the public interface of `decidim-pages`.
    # It mostly handles rendering the created page associated to a participatory
    # process.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Pages

      routes do
        resources :pages, only: [:show], controller: :application
        root to: "application#show"
      end

      initializer "decidim_pages.data_migrate", after: "decidim_core.data_migrate" do
        DataMigrate.configure do |config|
          config.data_migrations_path << root.join("db/data").to_s
        end
      end

      initializer "decidim_pages.shakapacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end
    end
  end
end
