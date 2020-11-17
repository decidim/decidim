# frozen_string_literal: true

module Decidim
  module Conferences
    # This type represents a conference.
    class ConferenceType < GraphQL::Schema::Object
      graphql_name "Conference"
      implements Decidim::Core::ParticipatorySpaceInterface
      implements Decidim::Core::ScopableInterface
      implements Decidim::Core::AttachableInterface
      implements Decidim::Core::TimestampsInterface

      description "A conference"

      field :id, ID, null: false, description: "Internal ID for this conference"
      field :shortDescription, Decidim::Core::TranslatedFieldType, null: true, description: "The short description of this conference" do
        def resolve(object:, arguments:, context:)
          object.short_description
        end
      end
      field :description, Decidim::Core::TranslatedFieldType, null: true, description: "The description of this conference"
      field :slug, String, null: true, description: "The slug of this conference"
      field :hashtag, String, null: true, description: "The hashtag for this conference"
      field :slogan, Decidim::Core::TranslatedFieldType, null: true, description: "The slogan of the conference"
      field :location, String, null: true, description: "The location of this conference"
      field :publishedAt, Decidim::Core::DateTimeType, null: true, description: "The time this conference was published" do
        def resolve(object:, arguments:, context:)
          object.published_at
        end
      end
      field :reference, String, null: true, description: "Reference prefix for this conference"

      field :heroImage, String, null: true, description: "The hero image for this conference" do
        def resolve(object:, arguments:, context:)
          object.hero_image
        end
      end
      field :bannerImage, String, null: true, description: "The banner image for this conference" do
        def resolve(object:, arguments:, context:)
          object.banner_image
        end
      end
      field :promoted, Boolean, null: true, description: "If this conference is promoted (therefore in the homepage)"
      field :objectives, Decidim::Core::TranslatedFieldType, null: true, description: "The objectives of the conference"
      field :showStatistics, Boolean, null: true, description: "If this conference shows the statistics" do
        def resolve(object:, arguments:, context:)
          object.show_statistics
        end
      end
      field :startDate, Decidim::Core::DateType, null: true, description: "The date this conference starts" do
        def resolve(object:, arguments:, context:)
          object.start_date
        end
      end
      field :endDate, Decidim::Core::DateType, null: true, description: "The date this conference ends" do
        def resolve(object:, arguments:, context:)
          object.end_date
        end
      end
      field :registrationsEnabled, Boolean, null: true, description: "If the registrations are enabled in this conference" do
        def resolve(object:, arguments:, context:)
          object.registrations_enabled
        end
      end
      field :availableSlots, Int, null: true, description: "The number of available slots in this conference" do
        def resolve(object:, arguments:, context:)
          object.available_slots
        end
      end
      field :registrationTerms, Decidim::Core::TranslatedFieldType, null: true, description: "The registration terms of this conference" do
        def resolve(object:, arguments:, context:)
          object.registration_terms
        end
      end

      field :speakers, [Decidim::Conferences::ConferenceSpeakerType], null: true, description: "List of speakers in this conference"
      field :partners, [Decidim::Conferences::ConferencePartnerType], null: true, description: "List of partners in this conference"
      field :categories, [Decidim::Core::CategoryType], null: true, description: "List of categories in this conference"
      field :mediaLinks, [Decidim::Conferences::ConferenceMediaLinkType], null: true, description: "List of media links in this conference" do
        def resolve(object:, arguments:, context:)
          object.media_links
        end
      end
    end
  end
end
