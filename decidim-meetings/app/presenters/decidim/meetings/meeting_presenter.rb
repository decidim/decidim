# frozen_string_literal: true

module Decidim
  module Meetings
    #
    # Decorator for meetings
    #
    class MeetingPresenter < Decidim::ResourcePresenter
      include Decidim::ResourceHelper
      include ActionView::Helpers::UrlHelper
      include Decidim::SanitizeHelper

      def meeting
        __getobj__
      end

      def meeting_path
        Decidim::ResourceLocatorPresenter.new(meeting).path
      end

      def display_mention
        link_to title, meeting_path
      end

      def title(links: false, html_escape: false, all_locales: false)
        return unless meeting

        super meeting.title, links, html_escape, all_locales
      end

      def description(links: false, extras: true, strip_tags: false, all_locales: false)
        return unless meeting

        new_description = handle_locales(meeting.description, all_locales) do |content|
          renderer = Decidim::ContentRenderers::HashtagRenderer.new(sanitized(content))
          renderer.render(links:).html_safe
        end

        content_handle_locale(new_description, all_locales, extras, links, strip_tags)
      end

      def location(all_locales: false)
        return unless meeting

        handle_locales(meeting.location, all_locales) do |content|
          content
        end
      end

      def location_hints(all_locales: false)
        return unless meeting

        handle_locales(meeting.location_hints, all_locales) do |content|
          content
        end
      end

      def registration_terms(all_locales: false)
        return unless meeting

        handle_locales(meeting.registration_terms, all_locales) do |content|
          content
        end
      end

      def closing_report(links: false, all_locales: false)
        return unless meeting

        handle_locales(meeting.closing_report, all_locales) do |content|
          renderer = Decidim::ContentRenderers::HashtagRenderer.new(sanitized(content))
          renderer.render(links:).html_safe
        end
      end

      def registration_email_custom_content(links: false, all_locales: false)
        return unless meeting

        handle_locales(meeting.registration_email_custom_content, all_locales) do |content|
          renderer = Decidim::ContentRenderers::HashtagRenderer.new(sanitized(content))
          renderer.render(links:).html_safe
        end
      end

      # start time and end time in rfc3339 format removing '-' and ':' symbols
      # joined with '/'. This format is used to generate the dates query param
      # in google calendars event link
      def dates_param
        return unless meeting

        [meeting.start_time, meeting.end_time].map do |date|
          date.rfc3339.tr("-:", "")
        end.join("/")
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

      def avatar_url(_variant = nil)
        ActionController::Base.helpers.asset_pack_path("media/images/decidim_meetings.svg")
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

      def proposals
        return unless Decidim::Meetings.enable_proposal_linking
        return unless meeting

        @proposals ||= meeting.authored_proposals.load
      end

      def formatted_proposals_titles
        return unless meeting

        proposals.map.with_index { |proposal, index| "#{index + 1}) #{proposal.title}\n" }
      end

      def sanitized(content)
        decidim_sanitize_editor(content)
      end
    end
  end
end
