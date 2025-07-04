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

      def title(html_escape: false, all_locales: false)
        return unless post

        super(post.title, html_escape, all_locales)
      end

      def body(links: nil, strip_tags: false, all_locales: false)
        return unless post

        raise "Links are being defined" unless links.nil?

        content_handle_locale(post.body, all_locales, links, strip_tags)
      end

      def taxonomy_names(html_escape: false, all_locales: false)
        post.taxonomies.map do |taxonomy|
          taxonomy.presenter.title(html_escape:, all_locales:)
        end
      end
    end
  end
end
