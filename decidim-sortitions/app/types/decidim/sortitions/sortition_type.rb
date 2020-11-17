# frozen_string_literal: true

module Decidim
  module Sortitions
    class SortitionType < GraphQL::Schema::Object
      graphql_name "Sortition"
      implements Decidim::Core::AuthorableInterface
      implements Decidim::Comments::CommentableInterface
      implements Decidim::Core::CategorizableInterface
      implements Decidim::Core::TimestampsInterface

      name
      description "A sortition"

      field :id, ID, null: false, description: "The internal ID for this sortition"
      field :dice, Int, null: true, description: "The dice for this sortition"
      field :targetItems, Int, null: true, description: "The target items for this sortition" do
        def resolve(object:, _args:, context:)
          object.target_items
        end
      end
      field :requestTimestamp, Decidim::Core::DateType, null: true, description: "The request time stamp for this request" do
        def resolve(object:, _args:, context:)
          object.request_timestamp
        end
      end
      field :selectedProposals, [Int], null: true, description: "The selected proposals for this sortition" do
        def resolve(object:, _args:, context:)
          object.selected_proposals
        end
      end
      field :witnesses, Decidim::Core::TranslatedFieldType, null: true, description: "The witnesses for this sortition"
      field :additionalInfo, Decidim::Core::TranslatedFieldType, null: true, description: "The additional info for this sortition" do
        def resolve(object:, _args:, context:)
          object.additional_info
        end
      end
      field :reference, String, null: true, description: "The reference for this sortition"
      field :title, Decidim::Core::TranslatedFieldType, null: true, description: "The title for this sortition"
      field :cancelReason, Decidim::Core::TranslatedFieldType, null: true, description: "The cancel reason for this sortition" do
        def resolve(object:, _args:, context:)
          object.cancel_reason
        end
      end
      field :cancelledOn, Decidim::Core::DateType, null: true, description: "When this sortition was cancelled" do
        def resolve(object:, _args:, context:)
          object.cancelled_on
        end
      end
      field :cancelledByUser, Decidim::Core::UserType, null: true, description: "Who cancelled this sortition" do
        def resolve(object:, _args:, context:)
          object.cancelled_by_user
        end
      end
      field :candidateProposals, Decidim::Core::TranslatedFieldType, null: true, description: "The candidate proposal for this sortition" do
        def resolve(object:, _args:, context:)
          object.candidate_proposals
        end
      end
    end
  end
end
