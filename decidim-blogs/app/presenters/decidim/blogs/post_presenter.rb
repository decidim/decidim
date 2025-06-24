# frozen_string_literal: true

module Decidim
  module Blogs
    #
    # Decorator for posts
    #
    class PostPresenter < Decidim::ResourcePresenter
      include Decidim::ResourceHelper
      include ActionView::Helpers::UrlHelper
      include Decidim::SanitizeHelper

      def author
        @author ||= if official?
                      Decidim::Blogs::OfficialAuthorPresenter.new
                    elsif user_group?
                      Decidim::UserGroupPresenter.new(super)
                    else
                      Decidim::UserPresenter.new(super)
                    end
      end

      def post
        __getobj__
      end

      def post_path
        Decidim::ResourceLocatorPresenter.new(post).path
      end

      def title(links: false, html_escape: false, all_locales: false)
        return unless post

        super(post.title, links, html_escape, all_locales)
      end

      def body(links: false, extras: true, strip_tags: false, all_locales: false)
        return unless post

        content_handle_locale(post.body, all_locales, extras, links, strip_tags)
      end
    end
  end
end
