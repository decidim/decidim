# frozen_string_literal: true

module Decidim
  module Conferences
    # This type represents a conference.
    ConferenceSpeakerType = GraphQL::ObjectType.define do
      name "ConferenceSpeaker"
      description "A conference speaker"

      field :id, !types.ID, "Internal ID of the speaker"
      field :fullName, types.String, "Full name of the speaker", property: :full_name
      field :position, Decidim::Core::TranslatedFieldType, "Position of the speaker in the conference"
      field :affiliation, Decidim::Core::TranslatedFieldType, "Affiliation of the speaker"
      field :twitterHandle, types.String, "Twitter handle", property: :twitter_handle
      field :shortBio, Decidim::Core::TranslatedFieldType, "Short biography of the speaker", property: :short_bio
      field :personalUrl, types.String, "Personal URL of the speaker", property: :personal_url
      field :avatar, types.String, "Avatar of the speaker"
      field :user, Decidim::Core::UserType, "Decidim user corresponding to this speaker", property: :user

      field :createdAt, Decidim::Core::DateTimeType, "The time this member was created ", property: :created_at
      field :updatedAt, Decidim::Core::DateTimeType, "The time this member was updated", property: :updated_at
    end
  end
end
