# frozen_string_literal: true

module Decidim
  module Consultations
    # This type represents a consultation.
    class ConsultationQuestionType < GraphQL::Schema::Object
      graphql_name "ConsultationQuestion"
      implements Decidim::Core::ScopableInterface
      implements Decidim::Core::AttachableInterface
      implements Decidim::Comments::CommentableInterface
      implements Decidim::Core::TimestampsInterface

      description "A consultation question"

      field :id, ID, null: false, description: "Internal ID of the question"
      field :title, Decidim::Core::TranslatedFieldType, null: true, description: "Title of the question"
      field :subtitle, Decidim::Core::TranslatedFieldType, null: true, description: "The subtitle of this question"
      field :slug, String, null: false, description: "Slug of the question"
      field :publishedAt, Decidim::Core::DateTimeType, null: false, description: "The time this question was published" do
        def resolve(object:, _args:, context:)
          object.published_at
        end
      end

      field :components, [Decidim::Core::ComponentInterface], null: true, description: "Lists the components this space contains." do
        def resolve(object:, _args:, context:)
          Decidim::Component.where(
            participatory_space: object
          ).published
        end
      end

      field :bannerImage, String, null: true, description: "The banner image for this question" do
        def resolve(object:, _args:, context:)
          object.banner_image
        end
      end
      field :heroImage, String, null: true, description: "The hero image for this question" do
        def resolve(object:, _args:, context:)
          object.hero_image
        end
      end

      field :whatIsDecided, Decidim::Core::TranslatedFieldType, null: true, description: "What is decided in this question" do
        def resolve(object:, _args:, context:)
          object.what_is_decided
        end
      end
      field :promoterGroup, Decidim::Core::TranslatedFieldType, null: true, description: "The promoter group of this question" do
        def resolve(object:, _args:, context:)
          object.promoter_group
        end
      end
      field :participatoryScope, Decidim::Core::TranslatedFieldType, null: true, description: "The participatory scope of this question" do
        def resolve(object:, _args:, context:)
          object.participatory_scope
        end
      end
      field :questionContext, Decidim::Core::TranslatedFieldType, null: true, description: "The context for this question" do
        def resolve(object:, _args:, context:)
          object.question_context
        end
      end
      field :reference, String, null: true, description: "The reference for this question" do
        def resolve(object:, _args:, context:)
          object.reference
        end
      end
      field :hashtag, String, null: true, description: "The hashtag of this question" do
        def resolve(object:, _args:, context:)
          object.hashtag
        end
      end
      field :votesCount, Int, null: true, description: "The number of votes in this question" do
        def resolve(object:, _args:, context:)
          object.votes_count
        end
      end
      field :originScope, Decidim::Core::TranslatedFieldType, null: true, description: "The origin scope of this question" do
        def resolve(object:, _args:, context:)
          object.origin_scope
        end
      end
      field :originTitle, Decidim::Core::TranslatedFieldType, null: true, description: "The origin title of this question" do
        def resolve(object:, _args:, context:)
          object.origin_title
        end
      end
      field :originUrl, String, null: true, description: "The origin URL for this question" do
        def resolve(object:, _args:, context:)
          object.origin_url
        end
      end
      field :iFrameUrl, String, null: true, description: "The iframe URL for this question" do
        def resolve(object:, _args:, context:)
          object.i_frame_url
        end
      end
      field :externalVoting, Boolean, null: true, description: "If the question has external voting" do
        def resolve(object:, _args:, context:)
          object.external_voting
        end
      end
      field :responsesCount, Int, null: true, description: "The number of responses for this question" do
        def resolve(object:, _args:, context:)
          object.responses_count
        end
      end
      field :order, Int, null: true, description: "The order in which the question should be represented"
      field :maxVotes, Int, null: true, description: "The maximum number of votes in this question" do
        def resolve(object:, _args:, context:)
          object.max_votes
        end
      end
      field :minVotes, Int, null: true, description: "The minimum number of votes in this question" do
        def resolve(object:, _args:, context:)
          object.min_votes
        end
      end
      field :responseGroupsCount, Int, null: true, description: "The number of group responses for this question" do
        def resolve(object:, _args:, context:)
          object.response_groups_count
        end
      end
      field :instructions, Decidim::Core::TranslatedFieldType, null: true, description: "Instructions for this question"
  end
  end
end
