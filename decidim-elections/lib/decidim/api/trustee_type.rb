# frozen_string_literal: true

module Decidim
  module Elections
    # This type represents an election trustee.
    class TrusteeType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::TraceableInterface

      description "A trustee for an election"

      field :id, GraphQL::Types::ID, "The internal ID of this trustee", null: false
      field :user, Decidim::Core::UserType, "The corresponding decidim user", null: true
      field :public_key, GraphQL::Types::String, "The public key of a trustee", null: true
    end
  end
end
