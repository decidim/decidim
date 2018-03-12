# frozen_string_literal: true

require "decidim/api/engine"

module Decidim
  # This module holds all business logic related to exposing a Public API for
  # decidim.
  module Api
    autoload :MutationType, "decidim/api/mutation_type"
    autoload :QueryType, "decidim/api/query_type"
    autoload :Schema, "decidim/api/schema"

    # This declares all the types an interface or union can resolve to. This needs
    # to be done in order to be able to have them found. This is a shortcoming of
    # graphql-ruby and the way it deals with loading types, in combination with
    # rail's infamous autoloading.
    def self.orphan_types
      Decidim.component_manifests.map(&:query_type).map(&:constantize).uniq +
        Decidim.participatory_space_manifests.map(&:query_type).map(&:constantize).uniq
    end
  end
end
