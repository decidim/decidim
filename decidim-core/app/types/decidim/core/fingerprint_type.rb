# frozen_string_literal: true

module Decidim
  module Core
    class FingerprintType< GraphQL::Schema::Object
     graphql_name "Fingerprint"
      description "A fingerprint object"

      field :value, String, null: false, description: "The the hash value for the fingerprint"
      field :source, String, null: false, description:"Returns the source String (usually a json) from which the fingerprint is generated."
    end
  end
end
