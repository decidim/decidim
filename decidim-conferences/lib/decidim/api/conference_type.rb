# frozen_string_literal: true

module Decidim
  module Conferences
    # This type represents a conference.
    class ConferenceType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::ParticipatorySpaceInterface
      implements Decidim::Core::ScopableInterface
      implements Decidim::Core::AttachableInterface

      description "A conference"

      field :id, GraphQL::Types::ID, "Internal ID for this conference", null: false
      field :short_description, Decidim::Core::TranslatedFieldType, "The short description of this conference", null: true
      field :description, Decidim::Core::TranslatedFieldType, "The description of this conference", null: true
      field :slug, GraphQL::Types::String, "The slug of this conference", null: true
      field :hashtag, GraphQL::Types::String, "The hashtag for this conference", null: true
      field :slogan, Decidim::Core::TranslatedFieldType, "The slogan of the conference", null: true
      field :location, String, "The location of this conference", null: true
      field :created_at, Decidim::Core::DateTimeType, "The time this conference was created", null: true
      field :updated_at, Decidim::Core::DateTimeType, "The time this conference was updated", null: true
      field :published_at, Decidim::Core::DateTimeType, "The time this conference was published", null: true
      field :reference, GraphQL::Types::String, "Reference prefix for this conference", null: true

      field :hero_image, GraphQL::Types::String, "The hero image for this conference", null: true
      field :banner_image, GraphQL::Types::String, "The banner image for this conference", null: true
      field :promoted, GraphQL::Types::Boolean, "If this conference is promoted (therefore in the homepage)", null: true
      field :objectives, Decidim::Core::TranslatedFieldType, "The objectives of the conference", null: true
      field :show_statistics, GraphQL::Types::Boolean, "If this conference shows the statistics", null: true
      field :start_date, Decidim::Core::DateType, "The date this conference starts", null: true
      field :end_date, Decidim::Core::DateType, "The date this conference ends", null: true
      field :registrations_enabled, GraphQL::Types::Boolean, "If the registrations are enabled in this conference", null: true
      field :available_slots, GraphQL::Types::Int, "The number of available slots in this conference", null: true
      field :registration_terms, Decidim::Core::TranslatedFieldType, "The registration terms of this conference", null: true

      field :speakers, [Decidim::Conferences::ConferenceSpeakerType, { null: true }], "List of speakers in this conference", null: true
      field :partners, [Decidim::Conferences::ConferencePartnerType, { null: true }], "List of partners in this conference", null: true
      field :categories, [Decidim::Core::CategoryType, { null: true }], "List of categories in this conference", null: true
      field :media_links, [Decidim::Conferences::ConferenceMediaLinkType, { null: true }], "List of media links in this conference", null: true
    end
  end
end
