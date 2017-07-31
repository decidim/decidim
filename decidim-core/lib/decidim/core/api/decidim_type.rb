# frozen_string_literal: true

module Decidim
  # This type represents a Decidim's global property.
  DecidimType = GraphQL::ObjectType.define do
    name "Decidim"
    description "Decidim's framework-related properties."

    field :version, !types.String, "The current decidim's version of this deployment." do
      resolve ->(obj, _args, _ctx) { obj.version }
    end

    field :application_name, !types.String, "The current installation's name." do
      resolve ->(obj, _args, _ctx) { obj.application_name }
    end
  end
end
