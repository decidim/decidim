# frozen_string_literal: true

module Decidim
  module Consultations
    # This type represents a consultation.
    class ConsultationType < GraphQL::Schema::Object
      graphql_name "Consultation"
      implements Decidim::Core::ParticipatorySpaceInterface
      implements Decidim::Core::TimestampsInterface

      description "A consultation"

      field :subtitle, Decidim::Core::TranslatedFieldType, null: true, description: "The subtitle of this consultation"
      field :description, Decidim::Core::TranslatedFieldType, null: true, description: "The description of this consultation"
      field :slug, String, null: false, description: "Slug of this consultation"
      field :publishedAt, Decidim::Core::DateTimeType, null: false, description: "The time this consultation was published" do
        def resolve(object:, arguments:, context:)
          object.published_at
        end
      end

      field :introductoryVideoUrl, String, null: true, description: "The introductory video url for this consultation" do
        def resolve(object:, arguments:, context:)
          object.introductory_video_url
        end
      end
      field :introductoryImage, String, null: true, description: "The introductory image for this consultation" do
        def resolve(object:, arguments:, context:)
          object.introductory_image
        end
      end
      field :bannerImage, String, null: true, description: "The banner image for this consultation" do
        def resolve(object:, arguments:, context:)
          object.banner_image
        end
      end
      field :highlightedScope, Decidim::Core::ScopeApiType, null: true, description: "This is the highlighted scope of this consultation" do
        def resolve(object:, arguments:, context:)
          object.highlighted_scope
        end
      end
      field :startVotingDate, Decidim::Core::DateType, null: true, description: "Start date of the voting for this consultation" do
        def resolve(object:, arguments:, context:)
          object.start_voting_date
        end
      end
      field :endVotingDate, Decidim::Core::DateType, null: true, description: "End date of the voting for this consultation" do
        def resolve(object:, arguments:, context:)
          object.end_voting_date
        end
      end
      field :resultsPublishedAt, Decidim::Core::DateType, null: true, description: "Date when the results have been published" do
        def resolve(object:, arguments:, context:)
          object.results_published_at
        end
      end

      field :questions, [Decidim::Consultations::ConsultationQuestionType], null: true, description: ""
    end
  end
end
