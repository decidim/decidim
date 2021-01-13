# frozen_string_literal: true

module Decidim
  module Consultations

    # This type represents a consultation.
    class ConsultationQuestionType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::ScopableInterface
      implements Decidim::Core::AttachableInterface
      implements Decidim::Comments::CommentableInterface

      description "A consultation question"

      field :id, ID, "Internal ID of the question", null: false
      field :title, Decidim::Core::TranslatedFieldType, "Title of the question", null: true
      field :subtitle, Decidim::Core::TranslatedFieldType, "The subtitle of this question", null: true
      field :slug, String, "Slug of the question", null: false
      field :created_at, Decidim::Core::DateTimeType, "The time this question was created", null: false
      field :updated_at, Decidim::Core::DateTimeType, "The time this question was updated", null: false
      field :published_at, Decidim::Core::DateTimeType, "The time this question was published", null: false

      field :components, [Decidim::Core::ComponentInterface, { null: true }], description: "Lists the components this space contains.", null: true

      def components
        Decidim::Component.where(
          participatory_space: object
        ).published
      end

      field :banner_image, String, "The banner image for this question", null: true
      field :hero_image, String, "The hero image for this question", null: true

      field :what_is_decided, Decidim::Core::TranslatedFieldType, "What is decided in this question", null: true
      field :promoter_group, Decidim::Core::TranslatedFieldType, "The promoter group of this question", null: true
      field :participatory_scope, Decidim::Core::TranslatedFieldType, "The participatory scope of this question", null: true
      field :question_context, Decidim::Core::TranslatedFieldType, "The context for this question", null: true
      field :reference, String, "The reference for this question", null: true
      field :hashtag, String, "The hashtag of this question", null: true
      field :votes_count, Integer, "The number of votes in this question", null: true
      field :origin_scope, Decidim::Core::TranslatedFieldType, "The origin scope of this question", null: true
      field :origin_title, Decidim::Core::TranslatedFieldType, "The origin title of this question", null: true
      field :origin_url, String, "The origin URL for this question", null: true
      field :i_frame_url, String, "The iframe URL for this question", null: true
      field :external_voting, Boolean, "If the question has external voting", null: true
      field :responses_count, Integer, "The number of responses for this question", null: true
      field :order, Integer, "The order in which the question should be represented", null: true
      field :max_votes, Integer, "The maximum number of votes in this question", null: true
      field :min_votes, Integer, "The minimum number of votes in this question", null: true
      field :response_groups_count, Integer, "The number of group responses for this question", null: true
      field :instructions, Decidim::Core::TranslatedFieldType, "Instructions for this question", null: true
    end
  end
end
