# frozen_string_literal: true

module Decidim
  module Blogs
    module Admin
      # Custom helpers used in posts views
      module PostsHelper
        include Decidim::ApplicationHelper
        include SanitizeHelper
        include PaginateHelper

        # Public: truncates the post body
        #
        # post - a Decidim::Blog instance
        # max_length - a number to limit the length of the body
        #
        # Returns the post's body truncated.
        def post_description_admin(post, max_length = 100)
          body = translated_attribute(post.body)
          CGI.unescapeHTML html_truncate(body, max_length:)
        end

        def post_author_select_field(form, name, _options = {})
          select_options = [
            [current_organization_name, ""]
          ]
          select_options << [current_user.name, current_user.id]

          unless form.object.author.is_a?(Organization) || select_options.pluck(1).include?(form.object.author.id)
            select_options << [form.object.author.name, form.object.author.id]
          end

          form.select(name, select_options)
        end

        def publish_data(published_at)
          data = {}
          if published_at > Time.current
            data[:icon] = icon("time-line", aria_label: t("decidim.blogs.admin.posts.index.not_published_yet"), role: "img")
            data[:popup] = t("decidim.blogs.admin.posts.index.not_published_yet")
          end
          data
        end
      end
    end
  end
end
