# frozen_string_literal: true

module Decidim
  module Consultations
    # This type represents a consultation.
    ConsultationType = GraphQL::ObjectType.define do
      interfaces [
        -> { Decidim::Core::ParticipatorySpaceInterface }
      ]

      name "Consultation"
      description "A consultation"

      field :subtitle, Decidim::Core::TranslatedFieldType, "The subtitle of this consultation"
      field :description, Decidim::Core::TranslatedFieldType, "The description of this consultation"
      field :slug, !types.String, "Slug of this consultation"
      field :createdAt, !Decidim::Core::DateTimeType, "The time this consultation was created", property: :created_at
      field :updatedAt, !Decidim::Core::DateTimeType, "The time this consultation was updated", property: :updated_at
      field :publishedAt, !Decidim::Core::DateTimeType, "The time this consultation was published", property: :published_at

      field :introductoryVideoUrl, types.String, "The introductory video url for this consultation", property: :introductory_video_url
      field :introductoryImage, types.String, "The introductory image for this consultation", property: :introductory_image
      field :bannerImage, types.String, "The banner image for this consultation", property: :banner_image
      field :highlightedScope, Decidim::Core::ScopeApiType, "This is the highlighted scope of this consultation", property: :highlighted_scope
      field :startVotingDate, Decidim::Core::DateType, "Start date of the voting for this consultation", property: :start_voting_date
      field :endVotingDate, Decidim::Core::DateType, "End date of the voting for this consultation", property: :end_voting_date
      field :resultsPublishedAt, Decidim::Core::DateType, "Date when the results have been published", property: :results_published_at

      field :questions, types[Decidim::Consultations::ConsultationQuestionType], ""
    end
  end
end
