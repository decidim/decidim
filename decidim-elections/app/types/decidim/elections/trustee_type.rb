# frozen_string_literal: true

module Decidim
  module Elections
    # This type represents an election trustee.
    class TrusteeType < GraphQL::Schema::Object
      graphql_name "Trustee"
      implements Decidim::Core::TraceableInterface

      description "A trustee for an election"

      field :id, ID, null: false, description: "The internal ID of this trustee"
      field :user, Decidim::Core::UserType, null: true, description: "The corresponding decidim user" do
        def resolve(object:, _args:, context:)
          object.user
        end
      end
      field :publicKey, String, null: true, description: "The public key of a trustee" do
        def resolve(object:, _args:, context:)
          object.public_key
        end
      end
    end
  end
end
