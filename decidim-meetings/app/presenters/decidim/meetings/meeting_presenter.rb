# frozen_string_literal: true

module Decidim
  module Meetings
    #
    # Decorator for meetings
    #
    class MeetingPresenter < SimpleDelegator
      include Decidim::TranslationsHelper
      include Decidim::ResourceHelper
      include Decidim::SanitizeHelper

      def meeting
        __getobj__
      end

      def title(links: false, all_locales: false)
        return unless meeting

        handle_locales(meeting.title, all_locales) do |content|
          renderer = Decidim::ContentRenderers::HashtagRenderer.new(decidim_html_escape(content))
          renderer.render(links: links).html_safe
        end
      end

      def description(links: false, all_locales: false)
        return unless meeting

        handle_locales(meeting.description, all_locales) do |content|
          renderer = Decidim::ContentRenderers::HashtagRenderer.new(decidim_sanitize(content))
          renderer.render(links: links).html_safe
        end
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
          renderer = Decidim::ContentRenderers::HashtagRenderer.new(decidim_sanitize(content))
          renderer.render(links: links).html_safe
        end
      end

      def registration_email_custom_content(links: false, all_locales: false)
        return unless meeting

        handle_locales(meeting.registration_email_custom_content, all_locales) do |content|
          renderer = Decidim::ContentRenderers::HashtagRenderer.new(decidim_sanitize(content))
          renderer.render(links: links).html_safe
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

      def avatar_url
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

      private

      def handle_locales(content, all_locales, &block)
        if all_locales
          content.each_with_object({}) do |(key, value), parsed_content|
            parsed_content[key] = if key == "machine_translations"
                                    handle_locales(value, all_locales, &block)
                                  else
                                    block.call(value)
                                  end
          end
        else
          yield(translated_attribute(content))
        end
      end
    end
  end
end
