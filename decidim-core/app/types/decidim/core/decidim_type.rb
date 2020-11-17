# frozen_string_literal: true

module Decidim
  module Core
    # This type represents a Decidim's global property.
    class DecidimType < GraphQL::Schema::Object
      graphql_name "Decidim"
      description "Decidim's framework-related properties."

      field :version, String, null: false, description: "The current decidim's version of this deployment."
      field :applicationName, String, null: false, description: "The current installation's name."

      delegate :version, to: :object

      def applicationName
        object.application_name
      end
    end
  end
end
