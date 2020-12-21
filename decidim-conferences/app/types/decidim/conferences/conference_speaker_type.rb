# frozen_string_literal: true

module Decidim
  module Conferences
    # This type represents a conference.
    class ConferenceSpeakerType < Decidim::Api::Types::BaseObject
      description "A conference speaker"

      field :id, ID, "Internal ID of the speaker", null: false
      field :full_name, String, "Full name of the speaker", null: true
      field :position, Decidim::Core::TranslatedFieldType, "Position of the speaker in the conference", null: true
      field :affiliation, Decidim::Core::TranslatedFieldType, "Affiliation of the speaker", null: true
      field :twitter_handle, String, "Twitter handle", null: true
      field :short_bio, Decidim::Core::TranslatedFieldType, "Short biography of the speaker", null: true
      field :personal_url, String, "Personal URL of the speaker", null: true
      field :avatar, String, "Avatar of the speaker", null: true
      field :user, Decidim::Core::UserType, "Decidim user corresponding to this speaker", null: true

      field :created_at, Decidim::Core::DateTimeType, "The time this member was created ", null: true
      field :updated_at, Decidim::Core::DateTimeType, "The time this member was updated", null: true
    end
  end
end
