# frozen_string_literal: true

module Decidim
  module Elections
    # This type represents an election trustee.
    TrusteeType = GraphQL::ObjectType.define do
      interfaces [
        -> { Decidim::Core::TraceableInterface }
      ]

      name "Trustee"
      description "A trustee for an election"

      field :id, !types.ID, "The internal ID of this trustee"
      field :user, Decidim::Core::UserType, "The corresponding decidim user", property: :user
      field :publicKey, types.String, "The public key of a trustee", property: :public_key
    end
  end
end
