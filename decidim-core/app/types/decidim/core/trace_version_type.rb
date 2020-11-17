# frozen_string_literal: true

module Decidim
  module Core
    class TraceVersionType < GraphQL::Schema::Object
      graphql_name "TraceVersion"
      description "A trace version type"

      field :id, ID, null: false, description: "The ID of the version"
      field :createdAt, Decidim::Core::DateTimeType, null: true, description: "The date and time this version was created"
      field :editor, Decidim::Core::AuthorInterface, null: true, description: "The editor/author of this version"
      field :changeset, GraphQL::Types::JSON, null: true, description: "Object with the changes in this version"

      def createdAt
        object.created_at
      end

      def editor
        author = Decidim.traceability.version_editor(object)
        author if author.is_a?(Decidim::User) || author.is_a?(Decidim::UserGroup)
      end

      delegate :changeset, to: :object
    end
  end
end
