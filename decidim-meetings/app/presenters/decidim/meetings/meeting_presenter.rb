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

      def title(links: false, locales: false)
        return unless meeting

        renderer = Decidim::ContentRenderers::HashtagRenderer.new(locales ? meeting.title : translated_attribute(meeting.title))
        renderer.render(links: links).html_safe
      end

      def description(links: false, locales: false)
        return unless meeting

        renderer = Decidim::ContentRenderers::HashtagRenderer.new(locales ? meeting.description : translated_attribute(meeting.description))
        renderer.render(links: links).html_safe
      end

      # Next methods are used for present a Meeting As Proposal Author
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

      def has_tooltip?
        false
      end
    end
  end
end
