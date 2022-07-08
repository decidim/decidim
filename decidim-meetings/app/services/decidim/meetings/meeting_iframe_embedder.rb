# frozen_string_literal: true

require "cgi"

module Decidim
  module Meetings
    # This class handles the streaming url to be included in the iframe present
    # in the live event. For some services it's required to transforma a bit
    # the structure of the URL.
    class MeetingIframeEmbedder
      # Public: Initializes the service.
      # online_meeting_service_url - A String containing the url of the online meeting
      def initialize(online_meeting_service_url)
        @online_meeting_service_url = online_meeting_service_url
      end

      def embed_transformed_url(request_host)
        return nil if parsed_online_meeting_uri.nil?

        case parsed_online_meeting_uri.host
        when "www.youtube.com"
          transform_youtube_url(parsed_online_meeting_uri)
        when "www.twitch.tv"
          transform_twitch_url(parsed_online_meeting_uri, request_host)
        else
          online_meeting_service_url
        end
      end

      def embeddable?
        return nil if parsed_online_meeting_uri.nil?

        embeddable_services.include?(parsed_online_meeting_uri.host)
      end

      def embed_code(request_host)
        return nil if parsed_online_meeting_uri.nil?

        %(
<div
  class="disabled-iframe"
  allow="camera; microphone; fullscreen; display-capture; autoplay"
  loading="lazy"
  src="#{embed_transformed_url(request_host)}"
  style="height: 100%; width: 100%; border: 0px;"
></div>
        )
      end

      private

      attr_accessor :online_meeting_service_url

      def embeddable_services
        @embeddable_services ||= Meetings.embeddable_services
      end

      # Youtube transformation consists on:
      # 1. extract the video id from the parameter v
      # 2. Create a new URL using the domain youtube-nocookie.com, converting it to an embed
      #    and appending the video id
      def transform_youtube_url(uri)
        return online_meeting_service_url if uri.query.blank?

        parsed_query = CGI.parse(uri.query)
        video_id = parsed_query.has_key?("v") ? CGI.parse(uri.query).fetch("v")&.first : nil

        return online_meeting_service_url if video_id.blank?

        "https://www.youtube-nocookie.com/embed/#{video_id}"
      end

      # Twitch transformation consists on:
      # 1. extract the video id from the third URL parameter
      # 2. extract the request host
      # 3. build the embed url using both the video ID and the request host as parent argument
      def transform_twitch_url(uri, request_host)
        _, param_name, video_id = *uri.path.split("/")

        return online_meeting_service_url if video_id.blank? || param_name != "videos"

        "https://player.twitch.tv/?video=#{video_id}&parent=#{request_host}"
      end

      def parsed_online_meeting_uri
        @parsed_online_meeting_uri ||= URI.parse(online_meeting_service_url) if online_meeting_service_url.present?
      end
    end
  end
end
