# frozen_string_literal: true
module Decidim
  # This type represents a ParticipatoryProcess.
  DecidimType = GraphQL::ObjectType.define do
    name "Decidim"
    description "Decidim's framework-related properties."

    field :version, !types.String, "The current decidim's version of this deployment." do
      resolve ->(obj, _args, _ctx) { obj.version }
    end
  end
end
