# frozen_string_literal: true

module Decidim
  module Core
    # This type represents a Decidim's global property.
    class DecidimType < Decidim::Api::Types::BaseObject
      description "Decidim's framework-related properties."

      field :application_name, GraphQL::Types::String, "The current installation's name.", null: false
      field :version, GraphQL::Types::String, "The current decidim's version of this deployment.", null: true

      def version
        object.version if Decidim::Api.disclose_system_version
      end
    end
  end
end
