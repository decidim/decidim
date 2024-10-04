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
      def post_description(post, max_length = 300)
        body = translated_attribute(post.body)
        CGI.unescapeHTML html_truncate(body, max_length:)
      end

      def render_schema_org_blog_posting_post(post)
        exported_post = Decidim::Exporters::JSON.new([post], SchemaOrgBlogPostingPostSerializer).export.read
        JSON.pretty_generate(JSON.parse(exported_post).first)
      end
    end
  end
end
