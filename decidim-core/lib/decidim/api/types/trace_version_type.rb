# frozen_string_literal: true

module Decidim
  module Core
    class TraceVersionType < Decidim::Api::Types::BaseObject
      description "A trace version type"

      field :id, GraphQL::Types::ID, "The ID of the version", null: false
      field :created_at, Decidim::Core::DateTimeType, description: "The date and time this version was created", null: true
      field :editor, Decidim::Core::AuthorInterface, description: "The editor/author of this version", null: true

      def editor
        author = Decidim.traceability.version_editor(object)
        author if author.is_a?(Decidim::User) || author.is_a?(Decidim::UserGroup)
      end
      field :changeset, GraphQL::Types::JSON, description: "Object with the changes in this version", null: true

      delegate :changeset, to: :object
    end
  end
end
