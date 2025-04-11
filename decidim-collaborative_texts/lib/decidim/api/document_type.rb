# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    class DocumentType < Decidim::Api::Types::BaseObject
      graphql_name "CollaborativeText"
      description "A collaborative text document."

      implements Decidim::Core::CoauthorableInterface
      implements Decidim::Core::TraceableInterface
      implements Decidim::Core::TimestampsInterface

      field :accepting_suggestions, GraphQL::Types::Boolean, "Whether this collaborative text document is accepting suggestions or not", null: true
      field :announcement, Decidim::Core::TranslatedFieldType, "The announcement of this collaborative text document.", null: true
      field :body, GraphQL::Types::String, "The body of this collaborative text document.", null: true
      field :document_versions, [Decidim::CollaborativeTexts::VersionType], "The versions of this collaborative text document.", null: true
      field :document_versions_count, GraphQL::Types::Int, "The number of versions for this collaborative text document.", null: true
      field :draft, GraphQL::Types::Boolean, "Whether this collaborative text document is a draft or not", null: true
      field :id, GraphQL::Types::ID, "The id of the collaborative text document", null: false
      field :published_at, Decidim::Core::DateTimeType, description: "The date and time this collaborative text document was published", null: true
      field :suggestions, [Decidim::CollaborativeTexts::SuggestionType], "The suggestions for this collaborative text document.", null: true
      field :suggestions_count, GraphQL::Types::Int, "The number of suggestions for this collaborative text document.", null: true
      field :title, GraphQL::Types::String, "The title of this collaborative text document.", null: false
      field :url, String, "The URL for this project", null: false

      def url
        Decidim::ResourceLocatorPresenter.new(object).url
      end
    end
  end
end
