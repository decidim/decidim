# frozen_string_literal: true

module Decidim
  module Blogs
    # A cell to display when a post has been created.
    class PostActivityCell < ActivityCell
      def title
        I18n.t(
          "new_post",
          scope: "decidim.blogs.last_activity"
        )
      end
    end
  end
end
