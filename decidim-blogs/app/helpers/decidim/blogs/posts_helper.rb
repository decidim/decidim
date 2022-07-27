# frozen_string_literal: true

module Decidim
  module Blogs
    # Custom helpers used in posts views
    module PostsHelper
      include Decidim::ApplicationHelper
      include Decidim::TranslationsHelper
      include Decidim::ResourceHelper

      # Public: truncates the post body
      #
      # post - a Decidim::Blog instance
      # max_length - a number to limit the length of the body
      #
      # Returns the post's body truncated.
      def post_description(post, max_length = 600)
        link = post_path(post)
        body = translated_attribute(post.body)
        tail = "... <br/> #{link_to(t("read_more", scope: "decidim.blogs"), link)}".html_safe
        CGI.unescapeHTML html_truncate(body, max_length:, tail:)
      end
    end
  end
end
