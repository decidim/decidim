# frozen_string_literal: true

module Decidim
  module Meetings
    #
    # Decorator for meetings
    #
    class MeetingPresenter < SimpleDelegator
      include Decidim::TranslationsHelper
      include Decidim::ResourceHelper

      def meeting
        __getobj__
      end

      def title
        return unless meeting
        renderer = Decidim::ContentRenderers::HashtagRenderer.new(translated_attribute(meeting.title))
        renderer.render_without_link.html_safe
      end

      def html_title
        return unless meeting
        renderer = Decidim::ContentRenderers::HashtagRenderer.new(translated_attribute(meeting.title))
        renderer.render.html_safe
      end

      def description
        return unless meeting
        renderer = Decidim::ContentRenderers::HashtagRenderer.new(translated_attribute(meeting.description))
        renderer.render_without_link.html_safe
      end

      def html_description
        return unless meeting
        renderer = Decidim::ContentRenderers::HashtagRenderer.new(translated_attribute(meeting.description))
        renderer.render.html_safe
      end

      # Used for presenter Meeting As Proposal Author
      def name
        title
      end

      def nickname
        ""
      end

      def badge
        ""
      end

      def profile_path
        resource_locator(meeting).path
      end

      def avatar_url
        ActionController::Base.helpers.asset_path("decidim/meetings/icon.svg")
      end

      def deleted?
        false
      end

      def can_be_contacted?
        false
      end
    end
  end
end
