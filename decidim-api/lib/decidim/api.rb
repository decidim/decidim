# frozen_string_literal: true

require "decidim/api/engine"

module Decidim
  # This module holds all business logic related to exposing a Public API for
  # decidim.
  module Api
    autoload :MutationType, "decidim/api/mutation_type"
    autoload :QueryType, "decidim/api/query_type"
    autoload :Schema, "decidim/api/schema"

    def self.orphan_types
      Decidim.feature_manifests.map(&:api_type).map(&:constantize).uniq +
        Decidim.participatory_space_manifests.map(&:api_type).map(&:constantize).uniq
    end
  end
end
