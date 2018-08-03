# frozen_string_literal: true

module Decidim
  module Core
    # This type represents a User.
    HashtagType = GraphQL::ObjectType.define do
      name "HashtagType"
      description "hashtags list"

      interfaces [
        -> { Decidim::Core::HashtagInterface }
      ]
    end
  end
end
