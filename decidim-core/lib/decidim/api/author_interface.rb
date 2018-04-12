# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents an author who owns a resource.
    AuthorInterface = GraphQL::InterfaceType.define do
      name "Author"
      description "An author"

      field :name, !types.String, "The author's name"
      field :nickname, !types.String, "The author's nickname"

      field :avatarUrl, !types.String, "The author's avatar url"
      field :profilePath, !types.String, "The author's profile path"
      field :badge, !types.String, "The author's badge icon"

      field :deleted, !types.Boolean, "Whether the author's account has been deleted or not"

      resolve_type ->(obj, _ctx) {
                     return Decidim::Core::UserType if obj.is_a? Decidim::User
                     return Decidim::Core::UserGroupType if obj.is_a? Decidim::UserGroup
                   }
    end
  end
end
