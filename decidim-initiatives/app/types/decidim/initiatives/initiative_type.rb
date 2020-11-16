# frozen_string_literal: true

module Decidim
  module Initiatives
    # This type represents a Initiative.
    InitiativeType = GraphQL::ObjectType.define do
      implements Decidim::Core::ParticipatorySpaceInterface
      implements Decidim::Core::ScopableInterface
      implements Decidim::Core::AttachableInterface
      implements Decidim::Core::AuthorInterface
      implements Decidim::Initiatives::InitiativeTypeInterface
      implements Decidim::Core::TimestampsInterface

      name "Initiative"
      description "A initiative"

      field :description, Decidim::Core::TranslatedFieldType, "The description of this initiative."
      field :slug, !types.String
      field :hashtag, types.String, "The hashtag for this initiative"
      field :publishedAt, !Decidim::Core::DateTimeType, "The time this initiative was published", property: :published_at
      field :reference, !types.String, "Reference prefix for this initiative"
      field :state, types.String, "Current status of the initiative"
      field :signatureType, types.String, "Signature type of the initiative", property: :signature_type
      field :signatureStartDate, !Decidim::Core::DateType, "The signature start date", property: :signature_start_date
      field :signatureEndDate, !Decidim::Core::DateType, "The signature end date", property: :signature_end_date
      field :offlineVotes, types.Int, "The number of offline votes in this initiative", property: :offline_votes
      field :initiativeVotesCount, types.Int, "The number of votes in this initiative", property: :initiative_votes_count
      field :initiativeSupportsCount, types.Int, "The number of supports in this initiative", property: :initiative_supports_count

      field :author, !Decidim::Core::AuthorInterface, "The initiative author" do
        resolve lambda { |obj, _args, _ctx|
          obj.user_group || obj.author
        }
      end

      field :committeeMembers, types[Decidim::Initiatives::InitiativeCommitteeMemberType], property: :committee_members
    end
  end
end
