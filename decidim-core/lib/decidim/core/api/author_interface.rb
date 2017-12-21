# frozen_string_literal: true

module Decidim
  # This interface represents an author who owns a resource.
  AuthorInterface = GraphQL::InterfaceType.define do
    name "Author"
    description "An author"

    field :name, !types.String, "The author's name"
    field :nickname, !types.String, "The author's nickname"

    field :avatarUrl, !types.String, "The author's avatar url"
    field :profilePath, !types.String, "The author's profile path"
    field :badgePath, !types.String, "The author's badge path"

    field :deleted, !types.Boolean, "Whether the author's account has been deleted or not"
  end
end
