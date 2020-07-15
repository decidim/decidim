# frozen_string_literal: true

module Decidim
  module Meetings
    MinutesType = GraphQL::ObjectType.define do
      name "MeetingMinutes"
      description "A meeting minutes"

      field :id, !types.ID, "The ID for the minutes"
      field :description, Decidim::Core::TranslatedFieldType, "The description for the minutes"
      field :videoUrl, types.String, "URL for the video of the session, if any", property: :video_url
      field :audioUrl, types.String, "URL for the audio of the session, if any", property: :audio_url
      # probably useful in the future, when handling user permissions
      # field :visible, !types.Boolean, "Whether this minutes is public or not", property: :visible

      field :createdAt, Decidim::Core::DateTimeType do
        description "The date and time this minutes was created"
        property :created_at
      end
      field :updatedAt, Decidim::Core::DateTimeType do
        description "The date and time this minutes was updated"
        property :updated_at
      end
    end
  end
end
