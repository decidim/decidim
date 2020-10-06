# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module EuRegistrations
    # This is the engine that runs on the public interface of eu_registrations.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::EuRegistrations

      routes do
        # Add engine routes here
        # resources :eu_registrations
        # root to: "eu_registrations#index"
      end

      initializer "decidim_eu_registrations.assets" do |app|
        app.config.assets.precompile += %w[decidim_eu_registrations_manifest.js decidim_eu_registrations_manifest.css]
      end
    end
  end
end
