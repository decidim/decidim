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

      initializer "decidim_templates.assets" do |app|
        app.config.assets.precompile += %w(decidim_templates_manifest.js decidim_templates_manifest.css)
      end
    end
  end
end
