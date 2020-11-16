# frozen_string_literal: true

module Decidim
  module Core
    # This type represents a User.
    class HashtagType< GraphQL::Schema::Object
      graphql_name "HashtagType"
      description "hashtags list"

      field :name, String, null: false, description: "The hashtag's name"
    end
  end
end
