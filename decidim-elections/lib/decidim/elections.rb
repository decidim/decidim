# frozen_string_literal: true

require "decidim/elections/admin"
require "decidim/elections/engine"
require "decidim/elections/admin_engine"
require "decidim/elections/component"

module Decidim
  # Base module for the elections engine.
  module Elections
    autoload :CensusManifest, "decidim/elections/census_manifest"

    # Public: Stores the registry of components
    def self.census_registry
      @census_registry ||= ManifestRegistry.new("elections/census")
    end
  end
end
