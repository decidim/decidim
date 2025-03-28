# frozen_string_literal: true

module Decidim
  module Conferences
    # This type represents a conference.
    class ConferenceSpeakerType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::TimestampsInterface

      description "A conference speaker"

      field :affiliation, Decidim::Core::TranslatedFieldType, "Affiliation of the speaker", null: true
      field :avatar, GraphQL::Types::String, "Avatar of the speaker", null: true
      field :full_name, GraphQL::Types::String, "Full name of the speaker", null: true
      field :id, GraphQL::Types::ID, "Internal ID of the speaker", null: false
      field :personal_url, GraphQL::Types::String, "Personal URL of the speaker", null: true
      field :position, Decidim::Core::TranslatedFieldType, "Position of the speaker in the conference", null: true
      field :published_at, Decidim::Core::DateTimeType, "The time this speaker was published", null: true
      field :short_bio, Decidim::Core::TranslatedFieldType, "Short biography of the speaker", null: true
      field :twitter_handle, GraphQL::Types::String, "X handle", null: true
      field :user, Decidim::Core::UserType, "Decidim user corresponding to this speaker", null: true

      def avatar
        object.attached_uploader(:avatar).url
      end

      def self.authorized?(object, context)
        chain = [
          allowed_to?(:list, :speakers, object, context),
          object.published?
        ].all?

        super && chain
      rescue Decidim::PermissionAction::PermissionNotSetError
        false
      end
    end
  end
end
