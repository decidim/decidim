# frozen_string_literal: true

module Decidim
  module Core
    TraceVersionType = GraphQL::ObjectType.define do
      name "TraceVersion"
      description "A trace version type"

      field :id, !types.ID, "The ID of the version"
      field :createdAt, Decidim::Core::DateTimeType do
        description "The date and time this version was created"
        property :created_at
      end
      field :editor, Decidim::Core::AuthorInterface do
        description "The editor/author of this version"
        resolve ->(obj, _args, _ctx) {
          author = Decidim.traceability.version_editor(obj)
          author if author.is_a?(Decidim::User) || author.is_a?(Decidim::UserGroup)
        }
      end
      field :changeset, GraphQL::Types::JSON do
        description "Object with the changes in this version"
        resolve ->(obj, _args, _ctx) {
          obj.changeset
        }
      end
    end
  end
end
