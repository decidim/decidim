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

      def proposals
        return unless meeting

        @proposals ||= meeting.authored_proposals.load
      end

      def formatted_proposals_titles
        return unless meeting

        proposals.map.with_index { |proposal, index| "#{index + 1}) #{proposal.title}\n" }
      end

      private

      def handle_locales(content, all_locales)
        if all_locales
          content.each_with_object({}) do |(locale, string), parsed_content|
            parsed_content[locale] = yield(string)
          end
        else
          yield(translated_attribute(content))
        end
      end
    end
  end
end
