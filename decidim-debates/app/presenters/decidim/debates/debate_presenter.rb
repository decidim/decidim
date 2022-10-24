# frozen_string_literal: true

module Decidim
  module Debates
    #
    # Decorator for debates
    #
    class DebatePresenter < Decidim::ResourcePresenter
      include Decidim::TranslationsHelper
      include Decidim::ResourceHelper
      include ActionView::Helpers::DateHelper

      def debate
        __getobj__
      end

      def author
        @author ||= if official?
                      Decidim::Debates::OfficialAuthorPresenter.new
                    elsif user_group
                      Decidim::UserGroupPresenter.new(user_group)
                    else
                      Decidim::UserPresenter.new(super)
                    end
      end

      def title(links: false, all_locales: false, html_escape: false)
        return unless debate

        super debate.title, links, html_escape, all_locales
      end

      def description(strip_tags: false, links: false, all_locales: false)
        return unless debate

        handle_locales(debate.description, all_locales) do |content|
          content = strip_tags(content) if strip_tags
          renderer = Decidim::ContentRenderers::HashtagRenderer.new(content)
          content = renderer.render(links:).html_safe
          content = Decidim::ContentRenderers::LinkRenderer.new(content).render if links
          content
        end
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
          author.is_a?(Decidim::User)
        end
      end

      def groups_count
        comments_authors.count do |author|
          author.is_a?(Decidim::UserGroup)
        end
      end

      private

      def comments_authors
        @comments_authors ||= debate.comments.includes(:author, :user_group).map(&:normalized_author).uniq
      end
    end
  end
end
