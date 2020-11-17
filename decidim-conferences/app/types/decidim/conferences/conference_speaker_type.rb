# frozen_string_literal: true

module Decidim
  module Conferences
    # This type represents a conference.
    class ConferenceSpeakerType < GraphQL::Schema::Object
      graphql_name "ConferenceSpeaker"
      description "A conference speaker"
      implements Decidim::Core::TimestampsInterface

      field :id, ID, null: false, description: "Internal ID of the speaker"
      field :fullName, String, null: true, description: "Full name of the speaker" do
        def resolve(object:, arguments:, context:)
          object.full_name
        end
      end
      field :position, Decidim::Core::TranslatedFieldType, null: true, description: "Position of the speaker in the conference"
      field :affiliation, Decidim::Core::TranslatedFieldType, null: true, description: "Affiliation of the speaker"
      field :twitterHandle, String, null: true, description: "Twitter handle" do
        def resolve(object:, arguments:, context:)
          object.twitter_handle
        end
      end
      field :shortBio, Decidim::Core::TranslatedFieldType, null: true, description: "Short biography of the speaker" do
        def resolve(object:, arguments:, context:)
          object.short_bio
        end
      end
      field :personalUrl, String, null: true, description: "Personal URL of the speaker" do
        def resolve(object:, arguments:, context:)
          object.personal_url
        end
      end
      field :avatar, String, null: true, description: "Avatar of the speaker"
      field :user, Decidim::Core::UserType, null: true, description: "Decidim user corresponding to this speaker"
  end
  end
end
