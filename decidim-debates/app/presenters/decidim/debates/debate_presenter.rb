# frozen_string_literal: true

module Decidim
  module Debates
    #
    # Decorator for debates
    #
    class DebatePresenter < Decidim::ResourcePresenter
      include Decidim::TranslationsHelper
      include Decidim::ResourceHelper
      include Decidim::SanitizeHelper
      include ActionView::Helpers::DateHelper

      def debate
        __getobj__
      end

      def author
        @author ||= if official?
                      Decidim::Debates::OfficialAuthorPresenter.new
                    else
                      Decidim::UserPresenter.new(super)
                    end
      end

      def title(html_escape: false, all_locales: false)
        return unless debate

        super(debate.title, html_escape, all_locales)
      end

      def description(strip_tags: false, extras: nil, links: false, all_locales: false)
        return unless debate

        raise "Extras being set" unless extras.nil?

        content_handle_locale(debate.description, all_locales, extras, links, strip_tags)
      end

      def last_comment_at
        return unless debate.last_comment_at

        time_ago_in_words(debate.last_comment_at)
      end

      def last_comment_by
        debate.last_comment_by&.presenter
      end

      def participants_count
        comments_authors.count do |author|
          author.is_a?(Decidim::User) && !author.group?
        end
      end

      private

      def comments_authors
        @comments_authors ||= debate.comments.includes(:author).map(&:author).uniq
      end
    end
  end
end
