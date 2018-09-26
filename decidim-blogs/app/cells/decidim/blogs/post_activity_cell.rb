# frozen_string_literal: true

module Decidim
  module Blogs
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
