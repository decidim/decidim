# frozen_string_literal: true

module Decidim
  module Sortitions
    SortitionType = GraphQL::ObjectType.define do
      interfaces [
        -> { Decidim::Core::AuthorableInterface },
        -> { Decidim::Comments::CommentableInterface },
        -> { Decidim::Core::CategorizableInterface }
      ]

      name "Sortition"
      description "A sortition"

      field :id, !types.ID, "The internal ID for this sortition"
      field :dice, types.Int, "The dice for this sortition"
      field :targetItems, types.Int, "The target items for this sortition", property: :target_items
      field :requestTimestamp, Decidim::Core::DateType, "The request time stamp for this request", property: :request_timestamp
      field :selectedProposals, types[types.Int], "The selected proposals for this sortition", property: :selected_proposals
      field :createdAt, Decidim::Core::DateTimeType, "When this sortition was created", property: :created_at
      field :updatedAt, Decidim::Core::DateTimeType, "When this sortition was updated", property: :updated_at
      field :witnesses, Decidim::Core::TranslatedFieldType, "The witnesses for this sortition"
      field :additionalInfo, Decidim::Core::TranslatedFieldType, "The additional info for this sortition", property: :additional_info
      field :reference, types.String, "The reference for this sortition"
      field :title, Decidim::Core::TranslatedFieldType, "The title for this sortition"
      field :cancelReason, Decidim::Core::TranslatedFieldType, "The cancel reason for this sortition", property: :cancel_reason
      field :cancelledOn, Decidim::Core::DateType, "When this sortition was cancelled", property: :cancelled_on
      field :cancelledByUser, Decidim::Core::UserType, "Who cancelled this sortition", property: :cancelled_by_user
      field :candidateProposals, Decidim::Core::TranslatedFieldType, "The candidate proposal for this sortition", property: :candidate_proposals
    end
  end
end
