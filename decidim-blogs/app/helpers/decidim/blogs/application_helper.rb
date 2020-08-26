# frozen_string_literal: true

module Decidim
  module Blogs
    # Custom helpers, scoped to the blogs engine.
    #
    module ApplicationHelper
      include PaginateHelper
      include SanitizeHelper
      include Decidim::Blogs::PostsHelper
      include ::Decidim::EndorsableHelper
      include ::Decidim::FollowableHelper
      include Decidim::Comments::CommentsHelper
    end
  end
end
