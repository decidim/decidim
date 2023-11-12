# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module Templates
    # This is the engine that runs on the public interface of templates.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Templates

      routes do
        # Add engine routes here
        resources :templates
        # root to: "templates#index"
      end

      initializer "decidim_templates.register_icons" do
        Decidim.icons.register(name: "clipboard-line", icon: "clipboard-line", resource: "core", category: "system", description: "", engine: :templates)
        Decidim.icons.register(name: "user-forbid-line", icon: "user-forbid-line", resource: "core", category: "system", description: "", engine: :templates)
      end

      initializer "decidim_templates.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end
    end
  end
end
