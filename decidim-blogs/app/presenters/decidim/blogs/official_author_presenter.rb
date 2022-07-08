# frozen_string_literal: true

module Decidim
  module Blogs
    #
    # A dummy presenter to abstract out the author of an official post.
    #
    class OfficialAuthorPresenter < Decidim::OfficialAuthorPresenter
      def name
        I18n.t("decidim.blogs.models.post.fields.official_blog_post")
      end
    end
  end
end
