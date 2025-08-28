# frozen_string_literal: true

module Decidim
  module Blogs
    # Custom helpers, scoped to the blogs engine.
    #
    module ApplicationHelper
      include PaginateHelper
      include SanitizeHelper
      include Decidim::Blogs::PostsHelper
      include ::Decidim::LikeableHelper
      include ::Decidim::FollowableHelper
      include Decidim::Comments::CommentsHelper

      def component_name
        (defined?(current_component) && translated_attribute(current_component&.name).presence) || t("decidim.components.blogs.name")
      end
    end
  end
end
