# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    class VersionType < Decidim::Api::Types::BaseObject
      graphql_name "DocumentVersion"
      description "A specific version for a collaborative text document."

      implements Decidim::Core::TraceableInterface
      implements Decidim::Core::TimestampsInterface

      field :body, GraphQL::Types::String, "The body of this collaborative text document version.", null: true
      field :document, Decidim::CollaborativeTexts::DocumentType, "The collaborative text document this version belongs to.", null: true
      field :draft, GraphQL::Types::Boolean, "Whether this collaborative text document version is a draft or not", null: true
      field :id, GraphQL::Types::ID, "The id of the collaborative text document version", null: false
      field :suggestions, [Decidim::CollaborativeTexts::SuggestionType, { null: true }], "The suggestions for this collaborative text document version.", null: true
      field :suggestions_count, GraphQL::Types::Int, "The number of suggestions for this collaborative text document version.", null: true
      field :title, GraphQL::Types::String, "The title of this collaborative text document version.", null: false
    end
  end
end
