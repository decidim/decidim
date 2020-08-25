# frozen_string_literal: true

module Decidim
  module Debates
    #
    # Decorator for debates
    #
    class DebatePresenter < SimpleDelegator
      include Decidim::SanitizeHelper
      include Decidim::TranslatableAttributes

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

      def title
        content = translated_attribute(debate.title)
        decidim_html_escape(content)
      end

      def description(strip_tags: false)
        content = translated_attribute(debate.description)
        content = strip_tags(content) if strip_tags
        content
      end

      def last_comment_by
        return unless comments_authors.any?

        comments.order("created_at DESC").first.normalized_author&.presenter
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
