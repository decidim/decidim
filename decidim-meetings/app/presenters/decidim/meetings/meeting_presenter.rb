# frozen_string_literal: true

module Decidim
  module Meetings
    #
    # Decorator for meetings
    #
    class MeetingPresenter < SimpleDelegator
      include Decidim::TranslationsHelper

      def meeting
        __getobj__
      end

      def title
        renderer = Decidim::ContentRenderers::HashtagRenderer.new(translated_attribute(meeting.title))
        renderer.render_without_link.html_safe
      end

      def html_title
        renderer = Decidim::ContentRenderers::HashtagRenderer.new(translated_attribute(meeting.title))
        renderer.render.html_safe
      end

      def description
        renderer = Decidim::ContentRenderers::HashtagRenderer.new(translated_attribute(meeting.description))
        renderer.render_without_link.html_safe
      end

      def html_description
        renderer = Decidim::ContentRenderers::HashtagRenderer.new(translated_attribute(meeting.description))
        renderer.render.html_safe
      end
    end
  end
end
