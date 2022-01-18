# frozen_string_literal: true

module Decidim
  module Sortitions
    class SortitionType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::AuthorableInterface
      implements Decidim::Comments::CommentableInterface
      implements Decidim::Core::CategorizableInterface

      description "A sortition"

      field :id, GraphQL::Types::ID, "The internal ID for this sortition", null: false
      field :dice, GraphQL::Types::Int, "The dice for this sortition", null: true
      field :target_items, GraphQL::Types::Int, "The target items for this sortition", null: true
      field :request_timestamp, Decidim::Core::DateType, "The request time stamp for this request", null: true
      field :selected_proposals, [GraphQL::Types::Int, { null: true }], "The selected proposals for this sortition", null: true
      field :created_at, Decidim::Core::DateTimeType, "When this sortition was created", null: true
      field :updated_at, Decidim::Core::DateTimeType, "When this sortition was updated", null: true
      field :witnesses, Decidim::Core::TranslatedFieldType, "The witnesses for this sortition", null: true
      field :additional_info, Decidim::Core::TranslatedFieldType, "The additional info for this sortition", null: true
      field :reference, GraphQL::Types::String, "The reference for this sortition", null: true
      field :title, Decidim::Core::TranslatedFieldType, "The title for this sortition", null: true
      field :cancel_reason, Decidim::Core::TranslatedFieldType, "The cancel reason for this sortition", null: true
      field :cancelled_on, Decidim::Core::DateType, "When this sortition was cancelled", null: true
      field :cancelled_by_user, Decidim::Core::UserType, "Who cancelled this sortition", null: true
      field :candidate_proposals, [GraphQL::Types::Int, { null: true }], "The candidate proposal for this sortition", null: true
    end
  end
end
