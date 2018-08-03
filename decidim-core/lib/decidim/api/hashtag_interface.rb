# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents an author who owns a resource.
    HashtagInterface = GraphQL::InterfaceType.define do
      name "HashtagInterface"
      description "A hashtag"

      field :name, !types.String, "The hashtag's name"
    end
  end
end
