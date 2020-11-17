# frozen_string_literal: true

module Decidim
  module Initiatives
    class InitiativeType < GraphQL::Schema::Object
      graphql_name "Initiative"
      # This type represents a Initiative.
      implements Decidim::Core::ParticipatorySpaceInterface
      implements Decidim::Core::ScopableInterface
      implements Decidim::Core::AttachableInterface
      implements Decidim::Core::AuthorInterface
      implements Decidim::Initiatives::InitiativeTypeInterface
      implements Decidim::Core::TimestampsInterface

      description "A initiative"

      field :description, Decidim::Core::TranslatedFieldType, null: true, description: "The description of this initiative."
      field :slug, String, null: false
      field :hashtag, String, null: true, description: "The hashtag for this initiative"
      field :publishedAt, Decidim::Core::DateTimeType, null: false, description: "The time this initiative was published" do
        def resolve(object:, _args:, context:)
          object.published_at
        end
      end
      field :reference, String, null: false, description: "Reference prefix for this initiative"
      field :state, String, null: true, description: "Current status of the initiative"
      field :signatureType, String, null: true, description: "Signature type of the initiative" do
        def resolve(object:, _args:, context:)
          object.signature_type
        end
      end
      field :signatureStartDate, Decidim::Core::DateType, null: false, description: "The signature start date" do
        def resolve(object:, _args:, context:)
          object.signature_start_date
        end
      end
      field :signatureEndDate, Decidim::Core::DateType, null: false, description: "The signature end date" do
        def resolve(object:, _args:, context:)
          object.signature_end_date
        end
      end
      field :offlineVotes, Int, null: true, description: "The number of offline votes in this initiative" do
        def resolve(object:, _args:, context:)
          object.offline_votes
        end
      end
      field :initiativeVotesCount, Int, null: true, description: "The number of votes in this initiative" do
        def resolve(object:, _args:, context:)
          object.initiative_votes_count
        end
      end
      field :initiativeSupportsCount, Int, null: true, description: "The number of supports in this initiative" do
        def resolve(object:, _args:, context:)
          object.initiative_supports_count
        end
      end

      field :author, Decidim::Core::AuthorInterface, null: false, description: "The initiative author" do
        def resolve(object:, _args:, context:)
          object.user_group || object.author
        end
      end

      field :committeeMembers, [Decidim::Initiatives::InitiativeCommitteeMemberType], null: true do
        def resolve(object:, _args:, context:)
          object.committee_members
        end
      end
    end
  end
end
