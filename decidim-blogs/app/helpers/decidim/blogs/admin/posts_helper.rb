# frozen_string_literal: true

module Decidim
  module Blogs
    module Admin
      # Custom helpers used in posts views
      module PostsHelper
        include Decidim::ApplicationHelper
        include SanitizeHelper

        # Public: truncates the post body
        #
        # post - a Decidim::Blog instance
        # max_length - a number to limit the length of the body
        #
        # Returns the post's body truncated.
        def post_description_admin(post, max_length = 100)
          body = translated_attribute(post.body)
          CGI.unescapeHTML html_truncate(body, max_length: max_length)
        end
      end
    end
  end
end
