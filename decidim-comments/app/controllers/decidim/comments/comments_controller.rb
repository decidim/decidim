# frozen_string_literal: true

module Decidim
  module Comments
    # Controller that manages the comments for a commentable object.
    #
    class CommentsController < Decidim::Comments::ApplicationController
      def create
        # TODO: Check permissions
        # TODO: Add comment
      end
    end
  end
end
