# frozen_string_literal: true

module Decidim
  module Initiatives
    # This type represents a Initiative.
    class InitiativeType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::ParticipatorySpaceInterface
      implements Decidim::Core::ScopableInterface
      implements Decidim::Core::AttachableInterface
      implements Decidim::Initiatives::InitiativeTypeInterface
      implements Decidim::Core::TimestampsInterface

      description "A initiative"

      field :author, Decidim::Core::AuthorInterface, "The initiative author", null: false
      field :committee_members, [Decidim::Initiatives::InitiativeCommitteeMemberType, { null: true }], "The committee members list", null: true
      field :description, Decidim::Core::TranslatedFieldType, "The description of this initiative.", null: true
      field :hashtag, GraphQL::Types::String, "The hashtag for this initiative", null: true
      field :initiative_supports_count, GraphQL::Types::Int,
            description: "The number of supports in this initiative",
            method: :online_votes_count,
            deprecation_reason: "initiativeSupportsCount has been collapsed in onlineVotes parameter",
            null: true
      field :initiative_votes_count, GraphQL::Types::Int,
            description: "The number of votes in this initiative",
            deprecation_reason: "initiativeVotesCount has been collapsed in onlineVotes parameter",
            null: true, method: :online_votes_count
      field :offline_votes, GraphQL::Types::Int, "The number of offline votes in this initiative", method: :offline_votes_count, null: true
      field :online_votes, GraphQL::Types::Int, "The number of online votes in this initiative", method: :online_votes_count, null: true
      field :published_at, Decidim::Core::DateTimeType, "The time this initiative was published", null: false
      field :reference, GraphQL::Types::String, "Reference prefix for this initiative", null: false
      field :signature_end_date, Decidim::Core::DateType, "The signature end date", null: false
      field :signature_start_date, Decidim::Core::DateType, "The signature start date", null: false
      field :signature_type, GraphQL::Types::String, "Signature type of the initiative", null: true
      field :slug, GraphQL::Types::String, "The slug of the initiative", null: false
      field :state, GraphQL::Types::String, "Current status of the initiative", null: true
      field :url, GraphQL::Types::String, "The URL of this initiative", null: true

      def url
        Decidim::EngineRouter.main_proxy(object).initiative_url(object)
      end
    end
  end
end
