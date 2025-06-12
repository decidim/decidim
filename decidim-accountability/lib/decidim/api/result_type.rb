# frozen_string_literal: true

module Decidim
  module Accountability
    class ResultType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::ReferableInterface
      implements Decidim::Comments::CommentableInterface
      implements Decidim::Core::AttachableInterface
      implements Decidim::Core::AttachableCollectionInterface
      implements Decidim::Core::LocalizableInterface
      implements Decidim::Core::TaxonomizableInterface
      implements Decidim::Core::TimestampsInterface
      implements Decidim::Core::TraceableInterface

      description "A result"

      field :children, [Decidim::Accountability::ResultType, { null: true }], "The children's results", null: true
      field :children_count, GraphQL::Types::Int, "The number of children results", null: true
      field :description, Decidim::Core::TranslatedFieldType, "The description for this result", null: true
      field :end_date, Decidim::Core::DateType, "The end date for this result", null: true
      field :external_id, GraphQL::Types::String, "The external ID for this result", null: true
      field :id, GraphQL::Types::ID, "The internal ID for this result", null: false
      field :parent, Decidim::Accountability::ResultType, "The parent result", null: true
      field :progress, GraphQL::Types::Float, "The progress for this result", null: true
      field :proposals, [Decidim::Proposals::ProposalType, { null: true }], "The proposal URLs for this result", null: true
      field :start_date, Decidim::Core::DateType, "The start date for this result", null: true
      field :status, Decidim::Accountability::StatusType, "The status for this result", null: true
      field :timeline_entries, [Decidim::Accountability::TimelineEntryType, { null: true }], "The timeline entries for this result", null: true
      field :title, Decidim::Core::TranslatedFieldType, "The title for this result", null: true
      field :url, String, "The URL for this result", null: false
      field :weight, GraphQL::Types::Int, "The order of this result", null: false

      def url
        Decidim::ResourceLocatorPresenter.new(object).url
      end

      def proposals
        object.linked_resources(:proposals, "included_proposals").sort_by(&:id)
      end
    end
  end
end
