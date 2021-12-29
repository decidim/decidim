# frozen_string_literal: true

module Decidim
  module Consultations
    # This type represents a consultation.
    class ConsultationType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::ParticipatorySpaceInterface

      description "A consultation"

      field :subtitle, Decidim::Core::TranslatedFieldType, "The subtitle of this consultation", null: true
      field :description, Decidim::Core::TranslatedFieldType, "The description of this consultation", null: true
      field :slug, GraphQL::Types::String, "Slug of this consultation", null: false
      field :created_at, Decidim::Core::DateTimeType, "The time this consultation was created", null: false
      field :updated_at, Decidim::Core::DateTimeType, "The time this consultation was updated", null: false
      field :published_at, Decidim::Core::DateTimeType, "The time this consultation was published", null: false

      field :introductory_video_url, GraphQL::Types::String, "The introductory video url for this consultation", null: true
      field :introductory_image, GraphQL::Types::String, "The introductory image for this consultation", null: true
      field :banner_image, GraphQL::Types::String, "The banner image for this consultation", null: true
      field :highlighted_scope, Decidim::Core::ScopeApiType, "This is the highlighted scope of this consultation", null: true
      field :start_voting_date, Decidim::Core::DateType, "Start date of the voting for this consultation", null: true
      field :end_voting_date, Decidim::Core::DateType, "End date of the voting for this consultation", null: true
      field :results_published_at, Decidim::Core::DateType, "Date when the results have been published", null: true

      field :questions, [Decidim::Consultations::ConsultationQuestionType, { null: true }], "", null: true

      def introductory_image
        object.attached_uploader(:introductory_image).path
      end

      def banner_image
        object.attached_uploader(:banner_image).path
      end
    end
  end
end
