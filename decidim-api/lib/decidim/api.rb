# frozen_string_literal: true

require "decidim/api/engine"
require "decidim/api/types"

module Decidim
  # This module holds all business logic related to exposing a Public API for
  # decidim.
  module Api
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
