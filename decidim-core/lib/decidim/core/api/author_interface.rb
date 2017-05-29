# frozen_string_literal: true

module Decidim
  # This interface represents an author who owns a resource.
  AuthorInterface = GraphQL::InterfaceType.define do
    name "Author"
    description "An author"

    field :name, !types.String, "The author's name"
    field :avatarUrl, !types.String, "The author's avatar url"
  end
end
