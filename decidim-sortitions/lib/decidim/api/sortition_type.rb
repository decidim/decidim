# frozen_string_literal: true

module Decidim
  module Sortitions
    class SortitionType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::AuthorableInterface
      implements Decidim::Comments::CommentableInterface
      implements Decidim::Core::TaxonomizableInterface
      implements Decidim::Core::TimestampsInterface
      implements Decidim::Core::ReferableInterface

      description "A sortition"

      field :additional_info, Decidim::Core::TranslatedFieldType, "The additional info for this sortition", null: true
      field :cancel_reason, Decidim::Core::TranslatedFieldType, "The cancel reason for this sortition", null: true
      field :cancelled_by_user, Decidim::Core::UserType, "Who cancelled this sortition", null: true
      field :cancelled_on, Decidim::Core::DateType, "When this sortition was cancelled", null: true
      field :candidate_proposals, [GraphQL::Types::Int, { null: true }], "The candidate proposal for this sortition", null: true
      field :dice, GraphQL::Types::Int, "The dice for this sortition", null: true
      field :id, GraphQL::Types::ID, "The internal ID for this sortition", null: false
      field :proposals, [Decidim::Proposals::ProposalType, { null: true }], "The selected proposal ids for this sortition", null: true
      field :request_timestamp, Decidim::Core::DateTimeType, "The request time stamp for this request", null: true
      field :selected_proposals, [GraphQL::Types::Int, { null: true }], "The selected proposal ids for this sortition", null: true
      field :target_items, GraphQL::Types::Int, "The target items for this sortition", null: true
      field :title, Decidim::Core::TranslatedFieldType, "The title for this sortition", null: true
      field :url, GraphQL::Types::String, "The URL for this sortition", null: false
      field :witnesses, Decidim::Core::TranslatedFieldType, "The witnesses for this sortition", null: true

      def url
        Decidim::ResourceLocatorPresenter.new(object).url
      end

      def self.authorized?(object, context)
        context[:sortition] = object

        super
      end
    end
  end
end
