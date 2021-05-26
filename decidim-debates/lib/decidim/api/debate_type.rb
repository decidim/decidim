# frozen_string_literal: true

module Decidim
  module Debates
    class DebateType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::CategorizableInterface
      implements Decidim::Comments::CommentableInterface
      implements Decidim::Core::AuthorableInterface
      implements Decidim::Core::ScopableInterface

      description "A debate"

      field :id, GraphQL::Types::ID, "The internal ID for this debate", null: false
      field :title, Decidim::Core::TranslatedFieldType, "The title for this debate", null: true
      field :description, Decidim::Core::TranslatedFieldType, "The description for this debate", null: true
      field :instructions, Decidim::Core::TranslatedFieldType, "The instructions for this debate", null: true
      field :start_time, Decidim::Core::DateTimeType, "The start time for this debate", null: true
      field :end_time, Decidim::Core::DateTimeType, "The end time for this debate", null: true
      field :image, GraphQL::Types::String, "The image of this debate", null: true
      field :created_at, Decidim::Core::DateTimeType, "When this debate was created", null: true
      field :updated_at, Decidim::Core::DateTimeType, "When this debate was updated", null: true
      field :information_updates, Decidim::Core::TranslatedFieldType, "The information updates for this debate", null: true
      field :reference, GraphQL::Types::String, "The reference for this debate", null: true
    end
  end
end
