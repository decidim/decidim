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
      implements Decidim::Core::FollowableInterface
      implements Decidim::Core::ReferableInterface
      implements Decidim::Comments::CommentableInterface

      description "A initiative"

      field :answer, Decidim::Core::TranslatedFieldType, "The answer of the initiative", null: true
      field :answer_url, GraphQL::Types::String, "The answer url of the initiative", null: true
      field :answered_at, Decidim::Core::DateTimeType, "The date this initiative was answered", null: true
      field :author, Decidim::Core::AuthorInterface, "The initiative author", null: false
      field :committee_members, [Decidim::Initiatives::InitiativeCommitteeMemberType, { null: true }], "The committee members list", null: true
      field :description, Decidim::Core::TranslatedFieldType, "The description of this initiative.", null: true
      field :first_progress_notification_at, Decidim::Core::DateTimeType, "The date when the first progress notification was sent ", null: true
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
      field :second_progress_notification_at, Decidim::Core::DateTimeType, " The date when the second progress notification was sent ", null: true
      field :signature_end_date, Decidim::Core::DateType, "The signature end date", null: false
      field :signature_start_date, Decidim::Core::DateType, "The signature start date", null: false
      field :signature_type, GraphQL::Types::String, "Signature type of the initiative", null: true
      field :slug, GraphQL::Types::String, "The slug of the initiative", null: false
      field :state, GraphQL::Types::String, "Current status of the initiative", null: true
      field :url, GraphQL::Types::String, "The URL of this initiative", null: true

      def url
        Decidim::EngineRouter.main_proxy(object).initiative_url(object)
      end

      def answer
        return unless object.answered?

        object.answer
      end

      def answer_url
        return unless object.answered?

        object.answer_url
      end
    end
  end
end
