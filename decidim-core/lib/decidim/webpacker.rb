# frozen_string_literal: true

module Decidim
  module Webpacker
    def self.register_path(path, prepend: false)
      deprecator.warn "Decidim::Webpacker.register_path is deprecated. Please use Decidim::Shakapacker.register_path instead."
      Decidim::Shakapacker.register_path(path, prepend:)
    end

    def self.register_entrypoints(entrypoints)
      deprecator.warn "Decidim::Webpacker.register_entrypoints is deprecated. Please use Decidim::Shakapacker.register_entrypoints instead."
      Decidim::Shakapacker.register_entrypoints(entrypoints)
    end

    def self.register_stylesheet_import(import, type: :imports, group: :app)
      deprecator.warn "Decidim::Webpacker.register_stylesheet_import is deprecated. Please use Decidim::Shakapacker.register_stylesheet_import instead."
      Decidim::Shakapacker.register_stylesheet_import(import, type:, group:)
    end

    def self.deprecator(gem_name: "decidim-core", deprecation_horizon: "0.32")
      require "active_support/deprecation"
      @deprecator ||= ActiveSupport::Deprecation.new(deprecation_horizon, gem_name)
    end
  end
end
