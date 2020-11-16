# frozen_string_literal: true

module Decidim
  module Meetings

    class MinutesType < GraphQL::Schema::Object
      graphql_name "MeetingMinutes"
      description "A meeting minutes"
      implements Decidim::Core::TimestampsInterface

      field :id, !types.ID, "The ID for the minutes"
      field :description, Decidim::Core::TranslatedFieldType, "The description for the minutes"
      field :videoUrl, types.String, "URL for the video of the session, if any", property: :video_url
      field :audioUrl, types.String, "URL for the audio of the session, if any", property: :audio_url
      # probably useful in the future, when handling user permissions
      # field :visible, !types.Boolean, "Whether this minutes is public or not", property: :visible

    end
  end
end
