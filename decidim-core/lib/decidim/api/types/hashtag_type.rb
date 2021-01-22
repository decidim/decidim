# frozen_string_literal: true

module Decidim
  module Core
    # This type represents a User.
    class HashtagType < Decidim::Api::Types::BaseObject
      graphql_name "HashtagType"
      description "hashtags list"

      field :name, GraphQL::Types::String, "The hashtag's name", null: false
    end
  end
end
