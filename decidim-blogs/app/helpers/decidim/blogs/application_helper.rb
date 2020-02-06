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
      include Decidim::Comments::CommentsHelper

      def follow_button_for(model, large = nil)
        render partial: "decidim/shared/follow_button.html", locals: { followable: model, large: large }
      end
    end
  end
end
