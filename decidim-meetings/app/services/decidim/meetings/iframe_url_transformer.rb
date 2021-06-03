# frozen_string_literal: true

require "cgi"

module Decidim
  module Meetings
    # This class handles the streaming url to be included in the iframe present
    # in the live event. For some services it's required to transforma a bit
    # the structure of the URL.
    class IframeUrlTransformer
      # Public: Initializes the service.
      # online_meeting_url - A String containing the url of the online meeting
      def initialize(online_meeting_url, request)
        @online_meeting_url = online_meeting_url
        @request = request
      end

      def transformed_url
        uri = URI.parse(online_meeting_url)

        case uri.host
        when "www.youtube.com"
          transform_youtube_url(uri)
        when "www.twitch.tv"
          transform_twitch_url(uri)
        else
          online_meeting_url
        end
      end

      private

      attr_accessor :online_meeting_url, :request

      # Youtube transformation consists on:
      # 1. extract the video id from the parameter v
      # 2. Create a new URL using the domain youtube-nocookie.com, converting it to an embed
      #    and appending the video id
      def transform_youtube_url(uri)
        return online_meeting_url if uri.query.blank?

        video_id = CGI.parse(uri.query).fetch("v")&.first

        return online_meeting_url if video_id.blank?

        "https://www.youtube-nocookie.com/embed/#{video_id}"
      end

      # Twitch transformation consists on:
      # 1. extract the video id from the third URL parameter
      # 2. extract the request host
      # 3. build the embed url using both the video ID and the request host as parent argument
      def transform_twitch_url(uri)
        _, param_name, video_id = *uri.path.split("/")

        return online_meeting_url if video_id.blank? || param_name != "videos"

        "https://player.twitch.tv/?video=#{video_id}&parent=#{request.host}"
      end
    end
  end
end
