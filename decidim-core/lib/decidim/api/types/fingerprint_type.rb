# frozen_string_literal: true

module Decidim
  module Core
    class FingerprintType < Decidim::Api::Types::BaseObject
      description "A fingerprint object"

      field :value, GraphQL::Types::String, "The the hash value for the fingerprint", null: false
      field :source, GraphQL::Types::String, description: "Returns the source String (usually a json) from which the fingerprint is generated.", null: false
    end
  end
end
