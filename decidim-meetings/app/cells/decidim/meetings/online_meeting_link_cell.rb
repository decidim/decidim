# frozen_string_literal: true

module Decidim
  module Meetings
    # This cell renders the online meeting link section
    # of a online or both type of meeting.
    class OnlineMeetingLinkCell < Decidim::Meetings::OnlineMeetingCell
      include Decidim::LayoutHelper

      def online_meeting_url?
        model.online_meeting_url.present?
      end

      delegate :embed_code, to: :embedder

      private

      def show_embed?
        model.iframe_embed_type_embed_in_meeting_page? && embedder.embeddable?
      end

      def iframe_container_meetings_css_class
        @iframe_container_meetings_css_class ||= begin
          css_class = ["meeting__iframe_container-"]

          case model.online_meeting_url
          when /youtube/
            css_class << "youtube"
          when /twitch/
            css_class << "twitch"
          when /meet\.jit\.si/
            css_class << "jitsi"
          when /vimeo/
            css_class << "vimeo"
            default
            ""
          end
          css_class.join(" ")
        end
      end
    end
  end
end
