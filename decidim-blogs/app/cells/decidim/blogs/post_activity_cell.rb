# frozen_string_literal: true

module Decidim
  module Blogs
    # A cell to display when a post has been created.
    class PostActivityCell < ActivityCell
      def title
        I18n.t(
          "decidim.blogs.last_activity.new_post_at_html",
          link: participatory_space_link
        )
      end
    end
  end
end
