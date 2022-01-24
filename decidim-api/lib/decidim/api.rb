# frozen_string_literal: true

require "decidim/api/engine"
require "decidim/api/types"

module Decidim
  # This module holds all business logic related to exposing a Public API for
  # decidim.
  module Api
    include ActiveSupport::Configurable

    # defines the schema max_per_page to configure GraphQL pagination
    config_accessor :schema_max_per_page do
      50
    end

    # defines the schema max_complexity to configure GraphQL query complexity
    config_accessor :schema_max_complexity do
      5000
    end

    # defines the schema max_depth to configure GraphQL query max_depth
    config_accessor :schema_max_depth do
      15
    end

    # This declares all the types an interface or union can resolve to. This needs
    # to be done in order to be able to have them found. This is a shortcoming of
    # graphql-ruby and the way it deals with loading types, in combination with
    # rail's infamous autoloading.
    def self.orphan_types
      Decidim.component_manifests.map(&:query_type).map(&:constantize).uniq +
        Decidim.participatory_space_manifests.map(&:query_type).map(&:constantize).uniq +
        (@orphan_types || [])
    end

    def self.add_orphan_type(type)
      @orphan_types ||= []
      @orphan_types += [type]
    end
  end
end
