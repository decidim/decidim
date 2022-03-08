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

        def post_author_select_field(form, name, _options = {})
          select_options = [
            [current_organization.name, ""],
            [current_user.name, current_user.id]
          ]
          select_options << [form.object.author.name, form.object.author.id] if form.object.author.is_a?(Decidim::User) && form.object.author.id != current_user.id
          if current_organization.user_groups_enabled? && Decidim::UserGroups::ManageableUserGroups.for(current_user).verified.any?
            user_groups = Decidim::UserGroups::ManageableUserGroups.for(current_user).verified
            select_options += user_groups.map { |g| [g.name, g.id] }
          end

          form.select(name, select_options)
        end
      end
    end
  end
end
