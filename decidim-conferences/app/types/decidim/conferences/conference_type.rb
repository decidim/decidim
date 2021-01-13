# frozen_string_literal: true

module Decidim
  module Conferences
    Decidim::Conference.include Decidim::Core::GraphQLApiTransition
    # This type represents a conference.
    ConferenceType = GraphQL::ObjectType.define do
      interfaces [
        -> { Decidim::Core::ParticipatorySpaceInterface },
        -> { Decidim::Core::ScopableInterface },
        -> { Decidim::Core::AttachableInterface }
      ]

      name "Conference"
      description "A conference"

      field :id, !types.ID, "Internal ID for this conference"
      field :shortDescription, Decidim::Core::TranslatedFieldType, "The short description of this conference", property: :short_description
      field :description, Decidim::Core::TranslatedFieldType, "The description of this conference"
      field :slug, types.String, "The slug of this conference"
      field :hashtag, types.String, "The hashtag for this conference"
      field :slogan, Decidim::Core::TranslatedFieldType, "The slogan of the conference"
      field :location, types.String, "The location of this conference"
      field :createdAt, Decidim::Core::DateTimeType, "The time this conference was created", property: :created_at
      field :updatedAt, Decidim::Core::DateTimeType, "The time this conference was updated", property: :updated_at
      field :publishedAt, Decidim::Core::DateTimeType, "The time this conference was published", property: :published_at
      field :reference, types.String, "Reference prefix for this conference"

      field :heroImage, types.String, "The hero image for this conference", property: :hero_image
      field :bannerImage, types.String, "The banner image for this conference", property: :banner_image
      field :promoted, types.Boolean, "If this conference is promoted (therefore in the homepage)"
      field :objectives, Decidim::Core::TranslatedFieldType, "The objectives of the conference"
      field :showStatistics, types.Boolean, "If this conference shows the statistics", property: :show_statistics
      field :startDate, Decidim::Core::DateType, "The date this conference starts", property: :start_date
      field :endDate, Decidim::Core::DateType, "The date this conference ends", property: :end_date
      field :registrationsEnabled, types.Boolean, "If the registrations are enabled in this conference", property: :registrations_enabled
      field :availableSlots, types.Int, "The number of available slots in this conference", property: :available_slots
      field :registrationTerms, Decidim::Core::TranslatedFieldType, "The registration terms of this conference", property: :registration_terms

      field :speakers, types[Decidim::Conferences::ConferenceSpeakerType], "List of speakers in this conference"
      field :partners, types[Decidim::Conferences::ConferencePartnerType], "List of partners in this conference"
      field :categories, types[Decidim::Core::CategoryType], "List of categories in this conference"
      field :mediaLinks, types[Decidim::Conferences::ConferenceMediaLinkType], "List of media links in this conference", property: :media_links
    end
  end
end
