# frozen_string_literal: true

module Decidim
  module Meetings
    class MinutesType < Decidim::Api::Types::BaseObject
      description "A meeting minutes"

      field :id, GraphQL::Types::ID, "The ID for the minutes", null: false
      field :description, Decidim::Core::TranslatedFieldType, "The description for the minutes", null: true
      field :video_url, GraphQL::Types::String, "URL for the video of the session, if any", null: true
      field :audio_url, GraphQL::Types::String, "URL for the audio of the session, if any", null: true

      # probably useful in the future, when handling user permissions
      # field :visible, !types.Boolean, "Whether this minutes is public or not", property: :visible
      #
      field :created_at, Decidim::Core::DateTimeType, description: "The date and time this minutes was created", null: true
      field :updated_at, Decidim::Core::DateTimeType, description: "The date and time this minutes was updated", null: true
    end
  end
end
