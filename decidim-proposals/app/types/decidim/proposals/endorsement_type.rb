# frozen_string_literal: true

module Decidim
  module Proposals
    EndorsementType = GraphQL::ObjectType.define do
      name "Endorsement"
      description "An endorsement"

      interfaces [
        Decidim::Core::AuthorableInterface
      ]
    end
  end
end
