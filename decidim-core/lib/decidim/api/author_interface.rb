# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents an author who owns a resource.
    module AuthorInterface
      include GraphQL::Schema::Interface
      # graphql_name "Author"
      # description "An author"

      field :id, GraphQL::Types::ID, null: false, description: "The author ID"
      field :name, GraphQL::Types::String, null: false, description: "The author's name"
      field :nickname, GraphQL::Types::String, null: false, description: "The author's nickname"

      field :avatarUrl, GraphQL::Types::String, null: false, description:  "The author's avatar url"
      field :profilePath, GraphQL::Types::String, null: false, description: "The author's profile path"
      field :badge, GraphQL::Types::String, null: false, description:  "The author's badge icon"
      field :organizationName, GraphQL::Types::String, null: false, description: "The authors's organization name"
      field :deleted, GraphQL::Types::Boolean, null: false, description: "Whether the author's account has been deleted or not"

      def organizationName
        object.organization.name
      end

      definition_methods do
        def resolve_type(object, context)
          if object.is_a?(Decidim::User)
            Decidim::Core::UserType
          elsif object.is_a?(Decidim::UserGroup)
            Decidim::Core::UserGroupType
          end
        end
      end

    end
  end
end
