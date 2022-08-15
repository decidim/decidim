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
          CGI.unescapeHTML html_truncate(body, max_length:)
        end

        def post_author_select_field(form, name, _options = {})
          select_options = [
            [current_organization.name, ""],
            [current_user.name, current_user.id]
          ]
          current_user_groups = Decidim::UserGroups::ManageableUserGroups.for(current_user).verified

          select_options += current_user_groups.map { |g| [g.name, g.id] } if current_organization.user_groups_enabled? && current_user_groups.any?
          unless form.object.author.is_a?(Organization) || select_options.pluck(1).include?(form.object.author.id)
            select_options << [form.object.author.name, form.object.author.id]
          end

          form.select(name, select_options)
        end

        def set_up_publicatin_time(published_at, created_at)
          result = {}
          result[:popup] = "Published"
          if published_at.nil?
            result[:status] = l created_at, format: "%d/%m/%Y - %H:%M"
          else
            result[:status] = l published_at, format: "%d/%m/%Y - %H:%M"
            if published_at >= Time.current
              result[:icon] = icon("clock", aria_label: "Not published yet", role: "img")
              result[:popup] = "Not published yet"
            end
          end
          result
        end
      end
    end
  end
end
