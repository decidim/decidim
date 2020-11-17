# frozen_string_literal: true

module Decidim
  module Meetings
    class MinutesType < GraphQL::Schema::Object
      graphql_name "MeetingMinutes"
      description "A meeting minutes"
      implements Decidim::Core::TimestampsInterface

      field :id, ID, null: false, description:  "The ID for the minutes"
      field :description, Decidim::Core::TranslatedFieldType,null: true , description:  "The description for the minutes"
      field :videoUrl, String,null: true , description:  "URL for the video of the session, if any" do
        def resolve(object:, _args:, context:)
          object.video_url
        end
      end
      field :audioUrl, String, null: true , description: "URL for the audio of the session, if any" do
        def resolve(object:, _args:, context:)
          object.audio_url
        end
      end
      # probably useful in the future, when handling user permissions
      # field :visible, !Boolean, "Whether this minutes is public or not", property: :visible
    end
  end
end
