# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    class SuggestionType < Decidim::Api::Types::BaseObject
      description "A suggestion for a collaborative text document version."

      implements Decidim::Core::TraceableInterface
      implements Decidim::Core::TimestampsInterface
      implements Decidim::Core::AuthorableInterface

      field :changeset, GraphQL::Types::JSON, "The changeset of this suggestion", null: false
      field :document_version, Decidim::CollaborativeTexts::VersionType, "The version this suggestion belongs to", null: false
      field :id, GraphQL::Types::ID, "The id of the suggestion", null: false
      field :status, GraphQL::Types::String, "The status of the suggestion", null: false
    end
  end
end
