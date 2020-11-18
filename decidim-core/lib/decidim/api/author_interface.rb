# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents an author who owns a resource.
    module AuthorInterface
      include GraphQL::Schema::Interface
      # graphql_name "Author"
      # description "An author"

      field :id, GraphQL::Types::ID, null: false, description: "The author ID"
      field :name, GraphQL::Types::String, null: false, description: "The author's name"do
        def resolve_field(object, args, context)
          object.presenter.name
        end
      end
      field :nickname, GraphQL::Types::String, null: false, description: "The author's nickname" do
        def resolve_field(object, args, context)
          object.presenter.nickname
        end
      end

      field :avatarUrl, GraphQL::Types::String, null: false, description: "The author's avatar url"do
        def resolve_field(object, args, context)
          object.presenter.avatar_url(:thumb)
        end
      end
      field :profilePath, GraphQL::Types::String, null: false, description: "The author's profile path"do
        def resolve_field(object, args, context)
          object.presenter.profile_path
        end
      end
      field :badge, GraphQL::Types::String, null: false, description: "The author's badge icon" do
        def resolve_field(object, args, context)
          object.presenter.badge
        end
      end
      field :organizationName, GraphQL::Types::String, null: false, description: "The authors's organization name" do
        def resolve_field(object, args, context)
          object.organization.name
        end
      end
      field :deleted, GraphQL::Types::Boolean, null: false, description: "Whether the author's account has been deleted or not"

      definition_methods do
        def resolve_type(object, _context)
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
