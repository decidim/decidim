# frozen_string_literal: true

require "devise/jwt"
require "warden/jwt_auth/decidim_overrides"
require "decidim/env"
require "decidim/api/engine"
require "decidim/api/types"
require "decidim/api/devise"

module Decidim
  # This module holds all business logic related to exposing a Public API for
  # decidim.
  module Api
    include ActiveSupport::Configurable

    # defines the schema max_per_page to configure GraphQL pagination
    config_accessor :schema_max_per_page do
      Decidim::Env.new("API_SCHEMA_MAX_PER_PAGE", 50).to_i
    end

    # defines the schema max_complexity to configure GraphQL query complexity
    config_accessor :schema_max_complexity do
      Decidim::Env.new("API_SCHEMA_MAX_COMPLEXITY", 5000).to_i
    end

    # defines the schema max_depth to configure GraphQL query max_depth
    config_accessor :schema_max_depth do
      Decidim::Env.new("API_SCHEMA_MAX_DEPTH", 15).to_i
    end

    config_accessor :disclose_system_version do
      Decidim::Env.new("DECIDIM_API_DISCLOSE_SYSTEM_VERSION").present?
    end

    # Public Setting that can make the API authentication necessary in order to
    # access it.
    config_accessor :force_api_authentication do
      Decidim::Env.new("DECIDIM_API_FORCE_API_AUTHENTICATION", nil).present?
    end

    # The expiration time of the jwt tokens, after which issued token to the
    # user will expired.
    config_accessor :jwt_expiration_time do
      Decidim::Env.new("DECIDIM_API_JWT_EXPIRATION_TIME", 60.minutes).to_i
    end

    # This declares all the types an interface or union can resolve to. This needs
    # to be done in order to be able to have them found. This is a shortcoming of
    # graphql-ruby and the way it deals with loading types, in combination with
    # rail's infamous auto-loading.
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
