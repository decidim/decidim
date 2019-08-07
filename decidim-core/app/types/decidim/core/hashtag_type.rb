# frozen_string_literal: true

module Decidim
  module Core
    # This type represents a User.
    HashtagType = GraphQL::ObjectType.define do
      name "HashtagType"
      description "hashtags list"

      field :name, !types.String, "The hashtag's name"
    end
  end
end
