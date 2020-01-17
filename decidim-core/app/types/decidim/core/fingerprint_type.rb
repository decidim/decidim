# frozen_string_literal: true

module Decidim
  module Core
    FingerprintType = GraphQL::ObjectType.define do
      name "Fingerprint"
      description "A fingerprint object"

      field :value, !types.String, "The the hash value for the fingerprint"
      field :source, !types.String do
        description "Returns the source String (usually a json) from which the fingerprint is generated."
      end
    end
  end
end
