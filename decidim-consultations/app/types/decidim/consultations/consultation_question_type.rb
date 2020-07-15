# frozen_string_literal: true

module Decidim
  module Consultations
    # This type represents a consultation.
    ConsultationQuestionType = GraphQL::ObjectType.define do
      interfaces [
        -> { Decidim::Core::ScopableInterface },
        -> { Decidim::Core::AttachableInterface },
        -> { Decidim::Comments::CommentableInterface }
      ]

      name "ConsultationQuestion"
      description "A consultation question"

      field :id, !types.ID, "Internal ID of the question"
      field :title, Decidim::Core::TranslatedFieldType, "Title of the question"
      field :subtitle, Decidim::Core::TranslatedFieldType, "The subtitle of this question"
      field :slug, !types.String, "Slug of the question"
      field :createdAt, !Decidim::Core::DateTimeType, "The time this question was created", property: :created_at
      field :updatedAt, !Decidim::Core::DateTimeType, "The time this question was updated", property: :updated_at
      field :publishedAt, !Decidim::Core::DateTimeType, "The time this question was published", property: :published_at

      field :components, types[Decidim::Core::ComponentInterface] do
        description "Lists the components this space contains."

        resolve ->(participatory_space, _args, _ctx) {
                  Decidim::Component.where(
                    participatory_space: participatory_space
                  ).published
                }
      end

      field :bannerImage, types.String, "The banner image for this question", property: :banner_image
      field :heroImage, types.String, "The hero image for this question", property: :hero_image

      field :whatIsDecided, Decidim::Core::TranslatedFieldType, "What is decided in this question", property: :what_is_decided
      field :promoterGroup, Decidim::Core::TranslatedFieldType, "The promoter group of this question", property: :promoter_group
      field :participatoryScope, Decidim::Core::TranslatedFieldType, "The participatory scope of this question", property: :participatory_scope
      field :questionContext, Decidim::Core::TranslatedFieldType, "The context for this question", property: :question_context
      field :reference, types.String, "The reference for this question", property: :reference
      field :hashtag, types.String, "The hashtag of this question", property: :hashtag
      field :votesCount, types.Int, "The number of votes in this question", property: :votes_count
      field :originScope, Decidim::Core::TranslatedFieldType, "The origin scope of this question", property: :origin_scope
      field :originTitle, Decidim::Core::TranslatedFieldType, "The origin title of this question", property: :origin_title
      field :originUrl, types.String, "The origin URL for this question", property: :origin_url
      field :iFrameUrl, types.String, "The iframe URL for this question", property: :i_frame_url
      field :externalVoting, types.Boolean, "If the question has external voting", property: :external_voting
      field :responsesCount, types.Int, "The number of responses for this question", property: :responses_count
      field :order, types.Int, "The order in which the question should be represented", property: :order
      field :maxVotes, types.Int, "The maximum number of votes in this question", property: :max_votes
      field :minVotes, types.Int, "The minimum number of votes in this question", property: :min_votes
      field :responseGroupsCount, types.Int, "The number of group responses for this question", property: :response_groups_count
      field :instructions, Decidim::Core::TranslatedFieldType, "Instructions for this question", property: :instructions
    end
  end
end
