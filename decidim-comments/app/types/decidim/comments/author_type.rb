# frozen_string_literal: true
module Decidim
  module Comments
    # This type represents an author who owns a resource
    AuthorType = GraphQL::ObjectType.define do
      name "Author"
      description "An author"

      field :name, !types.String
    end
  end
end
