# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents an author who owns a resource.
    module AuthorInterface
      include Decidim::Api::Types::BaseInterface
      graphql_name "Author"
      description "An author"

      field :id, ID, "The author ID", null: false
      field :name, String, "The author's name", null: false
      field :nickname, String, "The author's nickname", null: false

      field :avatar_url, String, "The author's avatar url", null: false
      field :profile_path, String, "The author's profile path", null: false
      field :badge, String, "The author's badge icon", null: false
      field :organization_name, String, "The authors's organization name", null: false

      def organization_name
        object.organization.name
      end

      field :deleted, Boolean, "Whether the author's account has been deleted or not", null: false

      def self.resolve_type(obj, _ctx)
        return Decidim::Core::UserType if obj.is_a? Decidim::User
        return Decidim::Core::UserGroupType if obj.is_a? Decidim::UserGroup
      end
    end
  end
end
