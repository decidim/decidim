# frozen_string_literal: true

require "cgi"

module Decidim
  module Meetings
    # This class handles the streaming url to be included in the iframe present
    # in the live event. For some services it is required to transform a bit
    # the structure of the URL.
    class MeetingIframeEmbedder
      # Hosts for which a single leading "www." or "m." prefix is stripped when
      # normalizing hostnames.
      PREFIX_STRIPPABLE_HOSTS = %w(youtube.com twitch.tv).freeze

      # YouTube URL paths whose last segment is the video id and that can be
      # rewritten directly to an embed URL.
      YOUTUBE_EMBED_PATH = %r{\A/(?:embed|live|shorts)/([^/]+)\z}

      # YouTube video ids only contain alphanumeric characters, hyphens and
      # underscores. Anything else (e.g. HTML or CSP payloads) is rejected so
      # that it is never interpolated into the embed URL.
      YOUTUBE_VIDEO_ID_REGEXP = /\A[A-Za-z0-9_-]+\z/

      # Public: Initializes the service.
      # online_meeting_service_url - A String containing the url of the online meeting
      def initialize(online_meeting_service_url)
        @online_meeting_service_url = online_meeting_service_url
      end

      def embed_transformed_url(request_host)
        return nil if parsed_online_meeting_uri.nil?

        case normalized_hostname
        when "youtube.com"
          transform_youtube_url(parsed_online_meeting_uri)
        when "twitch.tv"
          transform_twitch_url(parsed_online_meeting_uri, request_host)
        else
          online_meeting_service_url
        end
      end

      def embeddable?
        return nil if parsed_online_meeting_uri.nil?

        normalized_embeddable_services.include?(normalized_hostname)
      end

      def embed_code(request_host)
        return nil if parsed_online_meeting_uri.nil?

        <<~HTML
          <div class="disabled-iframe">
            <!-- <iframe
              allow="camera; microphone; fullscreen; display-capture; autoplay"
              loading="lazy"
              src="#{CGI.escapeHTML(embed_transformed_url(request_host).to_s)}"
              style="height: 100%; width: 100%; border: 0px;"></iframe> -->
          </div>
        HTML
      end

      private

      attr_accessor :online_meeting_service_url

      def embeddable_services
        @embeddable_services ||= Meetings.embeddable_services
      end

      def normalized_embeddable_services
        @normalized_embeddable_services ||= embeddable_services.map { |service| normalize_hostname(service) }
      end

      def normalized_hostname
        @normalized_hostname ||= normalize_hostname(parsed_online_meeting_uri.host)
      end

      # Strips a single leading "www." or "m." only when the remaining host is
      # youtube.com or twitch.tv. Any other host is returned unchanged so that
      # it is matched exactly. Only one prefix is removed so that multi-prefix
      # hosts (e.g. "www.m.youtube.com") are not considered equivalent.
      def normalize_hostname(hostname)
        stripped_hostname = hostname.to_s.sub(/\A(?:www|m)\./, "")

        PREFIX_STRIPPABLE_HOSTS.include?(stripped_hostname) ? stripped_hostname : hostname.to_s
      end

      # YouTube transformation consists on:
      # 1. extract the video id from the path (embed, live or shorts) or from the
      #    parameter v
      # 2. Create a new URL using the domain youtube-nocookie.com, converting it to an embed
      #    and appending the video id. Path-based URLs keep their original query string.
      def transform_youtube_url(uri)
        video_id, query = youtube_video_id_and_query(uri)

        return online_meeting_service_url if video_id.blank? || !video_id.match?(YOUTUBE_VIDEO_ID_REGEXP)

        "https://www.youtube-nocookie.com/embed/#{video_id}#{query}"
      end

      def youtube_video_id_and_query(uri)
        video_id = uri.path.to_s[YOUTUBE_EMBED_PATH, 1]

        if video_id.present?
          query = uri.query.present? ? "?#{uri.query}" : ""
          return [video_id, query]
        end

        [CGI.parse(uri.query.to_s)["v"]&.first, ""]
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
